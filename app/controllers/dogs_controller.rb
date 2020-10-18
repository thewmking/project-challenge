class DogsController < ApplicationController
  before_action :set_dog, only: [:show, :edit, :update, :destroy]
  before_action :set_page, only: :index

  # GET /dogs
  # GET /dogs.json
  def index
    params[:order] ||= "Created DESC"
    case params[:order]
    when "Created ASC"
      @dogs = Dog.order(created_at: :asc)
    when "Created DESC"
      @dogs = Dog.order(created_at: :desc)
    when "Most Likes"
      @dogs = Dog.left_joins(:likes).group(:id).order("COUNT(likes.id) DESC")
    when "Least Likes"
      @dogs = Dog.left_joins(:likes).group(:id).order("COUNT(likes.id) ASC")
    when "Most Likes Past Hour"
      @dogs = Dog.left_joins(:likes).group(:id).order("COUNT(likes.id) DESC").where("likes.created_at >= ?", 1.hour.ago)
      @dogs = @dogs + Dog.where.not(id: @dogs.pluck(:id))
    end
    if @dogs.kind_of?(Array)
      @dogs = @dogs[(@page * 5)..(@page * 5 + 5)]
    else
      @dogs = @dogs.limit(5).offset(@page * 5)
    end
    @dog_count = (Dog.all.count / 5.0).ceil
  end

  # GET /dogs/1
  # GET /dogs/1.json
  def show
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
    redirect_to @dog, notice: 'You do not have permission to edit this dog.' if @dog.user_id != current_user.id
  end

  # POST /dogs
  # POST /dogs.json
  def create
    @dog = Dog.new(dog_params)
    @dog.user_id = current_user.id

    respond_to do |format|
      if @dog.save
        params[:dog][:images].each do |image|
          @dog.images.attach(image)
        end

        format.html { redirect_to @dog, notice: 'Dog was successfully created.' }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1
  # PATCH/PUT /dogs/1.json
  def update
    respond_to do |format|
      if @dog.user_id != current_user.id
        format.html { redirect_to @dog, notice: 'You do not have permission to update this dog.' }
        format.json { render json: 'Permission Denied', status: :unauthorized }
      elsif @dog.update(dog_params)
        if params[:dog][:images].present?
          @dog.images.each { |i| i.destroy }
          params[:dog][:images].each do |image|
            @dog.images.attach(image)
          end
        end

        format.html { redirect_to @dog, notice: 'Dog was successfully updated.' }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.json
  def destroy
    @dog.destroy
    respond_to do |format|
      format.html { redirect_to dogs_url, notice: 'Dog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dog
      @dog = Dog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dog_params
      params.require(:dog).permit(:name, :description, :images)
    end

    def set_page
      @page = params[:page].to_i || 0
    end
end
