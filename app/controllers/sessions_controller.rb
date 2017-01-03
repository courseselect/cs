class SessionsController < ApplicationController
  include SessionsHelper

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.is_actived == false
      flash[:notice] = "您的账户处于未激活状态,请您通过邮箱激活! "
      user.update_attribute(:active_code , rand(Time.now.to_i).to_s)
      UserMailer.welcome_email(user).deliver
    elsif user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember_user(user) : forget_user(user)
      flash= {:info => "欢迎回来: #{user.name} :)"}
    else
      flash= {:danger => '账号或密码错误'}
    end
    redirect_to root_url, :flash => flash
  end

  def new

  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
  def getpwd

  end
  def sendgetpwdemail
    user = User.find_by(email: params[:session][:email].downcase)

    if user
      user.update_attribute(:password , rand(Time.now.to_i).to_s)
      flash[:notice] = "账户信息已发送注册邮箱"
      UserMailer.getmyacountsecret(user).deliver
    # else
    #   redirect_to new_user_path
    else
      flash[:notice] = "该账户未注册，请先注册"
    end
    redirect_to root_url

  end
  def pro_activate
    user = User.find_by_name(params[:name])
    if user != nil && user.is_actived == false && user.active_code == params[:active_code] then
   
      user.update_attribute(:is_actived , true)
      flash[:notice] = "恭喜您， 您已经成功激活了您的账户！ "

    elsif user != nil && user.is_actived == true then
      flash[:notice] = "您的账户已经处于激活状态， 请勿重复激活！ "
    else
      flash[:notice] = "激活失败！  "
    end
    redirect_to root_path

  end

end
