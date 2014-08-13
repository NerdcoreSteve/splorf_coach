class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /people
  # GET /people.json
  def index
    @people = policy_scope(Person)
  end

  # GET /people/1
  # GET /people/1.json
  def show
    authorize @person
  end

  # GET /people/new
  def new
    @person = Person.new
    authorize @person
  end

  # GET /people/1/edit
  def edit
    authorize @person
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)
    @person.user_id = current_user.id
    authorize @person

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render action: 'show', category: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, category: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    authorize @person
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @person.errors, category: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    authorize @person
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:first_name, :last_name, :description)
    end
end
