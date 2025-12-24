class Api::V1::CategoriesController < ApplicationController
  def create
    category = Category.create!(category_params)

    render json: {
      id: category.id,
      message: 'Category has been created successfully'
    }, status: :created
  end

  def show
    render json: {
      id: category.id,
      name: category.name,
      type: category.category_type,
      icon: category.icon
    }
  end

  def update
    category.update!(category_params)

    render json: {
      message: 'Category has been updated successfully',
      category: {
        id: category.id,
        name: category.name,
        type: category.category_type,
        icon: category.icon
      }
    }
  end

  def destroy
    category.destroy!

    render json: {
      message: 'Category has been deleted successfully'
    }
  end

  private

  def category
    @category ||= Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :type, :icon)
  end
end
