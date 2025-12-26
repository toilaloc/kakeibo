class Api::V1::Dropdowns::CategoriesController < ApplicationController
  def index
    categories = Category.select(:id, :name, :category_type)

    render json: { categories: }
  end
end
