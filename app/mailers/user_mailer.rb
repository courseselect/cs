class UserMailer < ApplicationMailer
  def welcome_email(user)
     @user = user
     mail(to: @user.email, subject: 'Welcome to CourseSelect Site')
  end
  def getmyacountsecret(user)
    @user = user
    mail(to: @user.email, subject: 'CourseSelect Site account information')
  end
end
