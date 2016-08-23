class DepartmentsController < ApplicationController

  before_filter :require_admin

  #
  # List out all Departments
  #
  def index
    @departments = Department.paginate(:page => params[:page], :per_page => 30)
  end

  #
  # Render a new Department form
  #
  def new
    @users = User.all
    @department = Department.new
  end

  #
  # Create a new department
  #
  def create
    #
    # If the form submitted nothing, redirect to home
    #
    if params[:department]
      #
      # Create new Department with data from the form
      #
      @department = Department.new(params[:department])
      if @department.save
        #
        # If successfuly saved, show message
        #
        flash[:notice] = "Successfuly added department."
        redirect_to departments_path
      else
        #
        # If problem occured, show an error
        #
        flash[:error] = "Could not add department."
        render :action => 'new'
      end

    else
      redirect_to new_department_path
    end
  end

  #
  # Render an edit form for given department
  #
  def edit
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end

    @department = Department.find(params[:id])
    @classes = [Client, Order, Store, BusinessManager, Comment, Message, Task, Document, Logotype, Address, Distributor, Distribution, Page, Option, Transport, Department, User]
  end

  #
  # Updates values of a current department
  #
  def update
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end

    @classes = [Client, Order, Store, BusinessManager, Comment, Message, Task, Document, Logotype, Address, Distributor, Distribution, Page, Option, Transport, Department, User]

    #
    # Find given department
    #
    @department = Department.find(params[:id])
    if @department.update_attributes(params[:department])

      #
      # Break down a string of users
      #
      assigned_string = params[:e15][:assigned_users]
      assigned = assigned_string.split(',')

      #
      # Assign the new users to the department
      #
      assigned.each do |name|
        user = User.find_by_name(name)
        user.update_attributes :department_id => @department.id
      end

      #
      # If the changes has been saved, show success message
      #
      flash[:notice] = "Department has been edited."
      redirect_to departments_path
    else
      #
      # Otherwise, show error messages
      #
      flash[:error] = "Could not edit department"
      render :action => 'new'
    end
  end

  #
  # Delete given department
  #
  def destroy
    if @department = Department.find(params[:id])
      #
      # Delete given department
      #
      @department.destroy
      flash[:notice] = "Department has been deleted."
    else
      flash[:error] = "Could not find department"
    end
    redirect_to departments_path
  end
end