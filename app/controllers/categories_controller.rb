class CategoriesController < ApplicationController
  layout 'single_card'
  before_action :set_category, only: [:edit, :update]

  def index
    @categories = Category.order(:danish)
    respond_to do |format|
      format.json { render json: @categories }
      format.html
    end
  end


  def new
    @category = Category.new
    render layout: nil
  end

  def show
  end

  def create
    @category = Category.new(whitelist_params)
    respond_to do |format|
      if @category.save
        format.html { render 'layouts/created', layout: nil }
        format.json { render json: @category, status: :created }
      else
        format.html { render action: 'new', layout: nil }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end

  end

  def edit
    render layout: nil
  end

  def update
    respond_to do |format|
      if @category.update(whitelist_params)
        format.html { render 'layouts/updated', layout: nil}
        format.json { head :no_content }
      else
        format.html { render action: 'edit', layout: nil }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  private
  def set_category
    @category = Category.find(params[:id])
  end

  def whitelist_params
    params.require(:category).permit(:english, :danish)
  end
end
