class UsersController < ApplicationController
  def require_login
    flash.alert = ["You are not logged in!"] if session[:user_id] == nil
    redirect_to '/register' if session[:user_id] == nil
  end
  def require_no_login
    flash.alert = ["You are already logged in!"] if session[:user_id] != nil
    redirect_to '/' if session[:user_id] != nil
  end
  before_action :require_login, only: [:logout, :display, :lend_to]
  before_action :require_no_login, except: [:logout, :display, :lend_to]
  def register
    #render page
  end
  def borrower
    params.permit!
    user = Borrower.create(params[:user])
    if user.errors.to_a.length > 0
      flash.alert = ["There were some errors with your registration:"] + user.errors.full_messages
      redirect_to "/register"
    else
      flash.notice = ["Successfully registered!"]
      session[:user_id] = -user.id
      redirect_to "/"
    end
  end
  def lender
    params.permit!
    user = Lender.create(params[:user])
    if user.errors.to_a.length > 0
      flash.alert = ["There were some errors with your registration:"] + user.errors.full_messages
      redirect_to "/register"
    else
      flash.notice = ["Successfully registered!"]
      session[:user_id] = user.id
      redirect_to "/"
    end
  end
  def login
    #render page
  end
  def do_login
      user = Lender.find_by_email(params[:email].downcase)
      puts user
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        flash.notice = ["Logged In!"]
        redirect_to "/"
      else
          user = Borrower.find_by_email(params[:email].downcase)
          puts user
          if user && user.authenticate(params[:password])
            session[:user_id] = -user.id
            flash.notice = ["Logged In!"]
            redirect_to "/"
          else
            flash.alert = ["There was an error in your login details."]
            redirect_to "/login"
          end
      end
  end
  def display
    if session[:user_id] < 0
      @user = Borrower.includes(:histories, :lenders).find(-session[:user_id])
      render "borrower"
    else
      @user = Lender.includes(:histories, borrowers: :histories).find(session[:user_id])
      @borrowers = Borrower.includes(:histories).all
      render "lender"
    end
  end
  def lend_to
    if session[:user_id] < 0
      flash.alert = ["You are a borrower, not a lender!"]
    else
      user = Lender.find(session[:user_id])
      if !params[:amount]
        flash.alert = ["You must input an amount to loan!"]
      elsif user.money < params[:amount].to_i
        flash.alert = ["Insufficient Funds!"]
      else
        user.money -= params[:amount].to_i
        user.save
        loan = user.histories.find_by_borrower_id(params[:borrower])
        if loan
          loan.amount += params[:amount].to_i
          loan.save
        else
          loan = History.create(amount: params[:amount].to_i, borrower_id: params[:borrower], lender_id: session[:user_id])
        end
        flash.notice = ["Loan granted!"]
      end
    end
    redirect_to '/'
  end

  def logout
    session[:user_id] = nil
    redirect_to "/login"
  end

end
