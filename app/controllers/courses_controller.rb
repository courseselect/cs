class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

 def open
     @course=Course.find_by_id(params[:id])
     @course.open =true
     @course.save
     redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
     
 end
  
  
  def close
     @course=Course.find_by_id(params[:id])
     @course.open=false
     @course.save
     redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end
  
  #-------------------------for students----------------------

  def list
   
    @course=Course.all
    @course_open=Course.where("open = ?", true)-current_user.courses
    @course_close=@course-@course_open
     @theparams=params
  end

  def select
    @course=Course.find_by_id(params[:id])
    if $is_opensystem == true
       if  @course.limit_num.nil? || @course.limit_num - @course.student_num > 0
           @course.student_num = @course.student_num + 1
           @course.update_attributes(:student_num => @course.student_num)
           @course.status= 2
           @course.update_attribute(:status,2)
           current_user.choosecoursesnumber = current_user.choosecoursesnumber+1
           current_user.update_attribute(:choosecoursesnumber,current_user.choosecoursesnumber)
           flash={:suceess => "成功选择课程: #{@course.name}"}
       else
           flash={danger: "课程已满: #{@course.name}"}
       end
    else
       @course.status=1
       @course.update_attribute(:status,1)
       current_user.prechoosecoursesnumber =current_user.prechoosecoursesnumber+1
       current_user.update_attribute(:prechoosecoursesnumber,current_user.prechoosecoursesnumber)

       flash={:suceess => "成功预选择课程: #{@course.name}"}
    end
    
    current_user.courses<<@course
    redirect_to list_courses_path, flash: flash
  end
    
  def prequit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    current_user.prechoosecoursesnumber = current_user.prechoosecoursesnumber-1
    current_user.update_attribute(:prechoosecoursesnumber,current_user.prechoosecoursesnumber)
    flash={:success => "成功取消预选课程: #{@course.name}"}
    redirect_to preindex_courses_path, flash: flash

  end
  
  def preindex
    @course=current_user.courses if student_logged_in?
  end
   
  def selectprecourses
    @course=current_user.courses
    @course.each do |course|
      if course.status==1
        course.update_attribute(:status ,2)
        current_user.choosecoursesnumber =current_user.choosecoursesnumber+ 1
        current_user.prechoosecoursesnumber =current_user.prechoosecoursesnumber-1
      end
    end
    current_user.update_attribute(:choosecoursesnumber,current_user.choosecoursesnumber)
    current_user.update_attribute(:prechoosecoursesnumber,current_user.prechoosecoursesnumber)
    redirect_to courses_path
  end
  
  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num =  @course.student_num - 1
    @course.update_attributes(:student_num => @course.student_num)
    current_user.choosecoursesnumber = current_user.choosecoursesnumber-1
    current_user.update_attribute(:choosecoursesnumber,current_user.choosecoursesnumber)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
 def xueweike
    @grades=current_user.grades.find_by(course_id: params[:id])
    @courseName = Course.find_by_id(params[:id]).name
    if @grades.xueweike == true then
      @grades.update_attributes(:xueweike => false)
      flash={:success => "#{@courseName}更改为非学位课"}
    else
      @grades.update_attributes(:xueweike => true)
      flash={:success => "#{@courseName}更改为学位课"}
    end
    redirect_to courses_path, flash: flash
 end
 
def prexueweike
    @grades=current_user.grades.find_by(course_id: params[:id])
    @courseName = Course.find_by_id(params[:id]).name
    if @grades.xueweike == true then
      @grades.update_attributes(:xueweike => false)
      flash={:success => "#{@courseName}更改为非学位课"}
    else
      @grades.update_attributes(:xueweike => true)
      flash={:success => "#{@courseName}更改为学位课"}
    end
    redirect_to preindex_courses_path, flash: flash
end

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    if student_logged_in?
      @course=current_user.courses
      @selectedcourse=Array.new
      @course.each do |course|
        if course.status==2
          @selectedcourse.push(course)
        end
      end
      @course=@selectedcourse
    end
    @courses = Course.order(:name)
    
    

    #导出文件功能
    respond_to do |format|
      format.html
      format.csv { send_data @courses.to_csv }
      format.xls { send_data @courses.to_csv(col_sep: "\t") }
    end
  end
  
def search
    temp="%"+params[:name]+"%"
    @theparams=Course.find_by_id(1)
    @course=Course.all
    @course_open=Course.where("name like ? AND open =?", temp ,true)
    @course_close=Course.where("name like ? AND open =?", temp ,false)

    if params[:teaching_type]!=""
        @course_open=@course_open.where("teaching_type =?", params[:teaching_type])
        @course_close=@course_close.where("teaching_type =?", params[:teaching_type])
    end
    if params[:course_type]!=""
      @course_open=@course_open.where("course_type =?", params[:course_type])
      @course_close=@course_close.where("course_type =?", params[:course_type])
    end
    if params[:credit]!=""
      @course_open=@course_open.where("credit =?", params[:credit])
      @course_close=@course_close.where("credit =?", params[:credit])
    end
    if params[:exam_type]!=""
      @course_open=@course_open.where("exam_type =?", params[:exam_type])
      @course_close=@course_close.where("exam_type =?", params[:exam_type])
    end
    @course_open=@course_open-current_user.courses
    @course_close=@course_close-current_user.courses
    @theparams=params
    render 'list'
end

 def refresh_search
    @course=Course.all
    @course_open=Course.where("open = ?", true)-current_user.courses
    @course_close=@course-@course_open
    @theparams=params
    render 'list'
 end

  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
