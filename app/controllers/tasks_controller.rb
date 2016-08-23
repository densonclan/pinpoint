class TasksController < ApplicationController

  before_filter :find_task, only: [:show, :edit, :update, :destroy, :archive, :unarchive]
  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy, :archive, :unarchive]

  def index
    @tasks = current_user.assigned_tasks_include_departments.unarchived.ordered.page(params[:page])
  end

  #
  # Render assigned to the logged in user tasks in a calendar form
  #
  def calendar
    @date = params[:month] ? Date.parse(params[:month].gsub('-','/')) : Date.today
    @tasks = Task.for_user_or_department(current_user).unarchived
    @periods = Period.accessible_by(current_ability).all
  end

  def assigned
    @tasks = current_user.tasks.unarchived.page(params[:page])
  end

  #
  # List all archived, assigned to the logged in user tasks
  #
  def archived
    @tasks = current_user.assigned_tasks.archived.paginate(:page => params[:page], :per_page => 30)
  end

  #
  # List all tasks related to a given store
  #
  def store
    @store = Store.find(params[:id])
    @tasks = @store.tasks.paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @task = Task.new due_date: params[:date]
  end

  def create
    @task = Task.new_with_user(params[:task], current_user)
    if @task.save
      redirect_to tasks_path, notice: 'Task created successfully'
    else
      flash[:error] = "Could not save the task."
      render :new
    end
  end

  #
  # Render a form to edit a given task
  #
  def edit
    @users = User.accessible_by(current_ability).all
    @departments = Department.accessible_by(current_ability).all
  end

  #
  # Update a given task with details form the edit form
  #
  def update
    @users = User.accessible_by(current_ability).all
    @departments = Department.accessible_by(current_ability).all

    if @task.update_attributes(params[:task])
      flash[:notice] = "Changes have been saved."
      redirect_to tasks_path
    else
      flash[:error] = "Could not save the changes."
      render :action => 'edit'
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: 'Task has been deleted.'
  end

  def archive
    @task.archive!
    redirect_to tasks_path, notice: "Task archived."
  end

  def unarchive
    @task.unarchive!
    redirect_to tasks_path, notice: "Task has been restored."
  end

  private

  def find_task
    @task = Task.accessible_by(current_user).find(params[:id])
  end
end