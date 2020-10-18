class LikesController < ApplicationController

  def create
    dog = Dog.find(params[:dog_id])
    if !Like.where(user_id: current_user.id, dog_id: params[:dog_id]).present? && dog.present?
      Like.create(user: current_user, dog: dog)
      render json: { likes: dog.likes.count, dog_id: dog.id }
    else
      render json: { message: 'You have already liked this dog.'}
    end
  end

  def destroy
    dog = Dog.find(params[:id])
    like = current_user.likes.where(dog_id: params[:id]).first
    if like
      like.destroy
      render json: { likes: dog.likes.count, dog_id: dog.id }
    end
  end

end
