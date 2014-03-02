class Admin::NewIssuesController < AdminController
  before_filter :authorize_edit

  def edit
    @issue = Issue.find(params[:id])
    @sections = {
      intro: 'Intro',
      propositions: 'Forslag',
      promises: 'Løfter',
      positions: 'Posisjoner',
      party_comments: 'Partikommentarer'
    }
  end

  private

  def authorize_edit
    unless policy(@issue || Issue.new).edit?
      flash.alert = t('app.errors.unauthorized')
      redirect_to admin_root_path
    end
  end

end
