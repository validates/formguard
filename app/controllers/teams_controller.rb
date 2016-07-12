class TeamsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @teams = current_user.teams
  end

  def create
    @team = Team.create(team_params)
    if @team.save
      @team.members << current_user
      flash[:notice] = "Team created!"
      redirect_to authenticated_root_path
    else
      head 500
    end
  end

  def show
    @memberships = @team.memberships.includes(:member)
    @form_actions = @team.form_actions
    @form_action = FormAction.new
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end

  def authenticate_user!
    unless current_user
      redirect_to new_user_session_path, error: "You need to be signed in"
    end
  end
end
