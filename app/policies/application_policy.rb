class ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.where(:user_id => user.id)
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "Must be signed in." unless user
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    belongs_to_user?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    belongs_to_user?
  end

  def edit?
    update?
  end

  def destroy?
    belongs_to_user?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def belongs_to_user?
    scope.where(:id => record.id).exists?
  end
end
