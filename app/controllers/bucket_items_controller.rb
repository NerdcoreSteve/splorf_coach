class BucketItemsController < ApplicationController
  before_action :set_bucket_item, only: [:show, :edit, :update, :destroy]

  # GET /bucket_items
  # GET /bucket_items.json
  def index
    @bucket_items = policy_scope(BucketItem)
  end

  # GET /bucket_items/1
  # GET /bucket_items/1.json
  def show
    authorize @bucket_item
  end

  # GET /bucket_items/new
  def new
    @bucket_item = BucketItem.new
    authorize @bucket_item
  end

  # GET /bucket_items/1/edit
  def edit
    authorize @bucket_item
  end

  # POST /bucket_items
  # POST /bucket_items.json
  def create
    @bucket_item = BucketItem.new(bucket_item_params)
    @bucket_item.user_id = current_user.id
    authorize @bucket_item

    respond_to do |format|
      if @bucket_item.save
        format.html { redirect_to @bucket_item, notice: 'BucketItem was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bucket_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @bucket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bucket_items/1
  # PATCH/PUT /bucket_items/1.json
  def update
    authorize @bucket_item
    respond_to do |format|
      if @bucket_item.update(bucket_item_params)
        format.html { redirect_to @bucket_item, notice: 'BucketItem was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bucket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bucket_items/1
  # DELETE /bucket_items/1.json
  def destroy
    authorize @bucket_item
    @bucket_item.destroy
    respond_to do |format|
      format.html { redirect_to bucket_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bucket_item
      @bucket_item = BucketItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bucket_item_params
      params.require(:bucket_item).permit(:name, :bucket_item_type, :bucket, :description, :status)
    end
end
