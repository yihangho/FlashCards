class TodosController < ApplicationController
  def index
    @todos = Todo.all
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.create(todo_params)
    if @todo.save
      redirect_to todos_path
    else
      render 'new'
    end
  end

  def edit
    begin
      @todo = Todo.find(params[:id])
    rescue
      render_404 "There is no such TODO."
    end
  end

  def update
    begin
      @todo = Todo.find(params[:id])
      if @todo.update_attributes(todo_params)
        redirect_to todos_path
      else
        render 'edit'
      end
    rescue
      render_404 "There is no such TODO."
    end
  end

  def new_card
    todo = Todo.find_by(:id => params[:id])
    if todo
      @card = Card.new(:word => todo.word)
      render 'cards/new'
    else
      redirect_to todos_path
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:word)
  end
end
