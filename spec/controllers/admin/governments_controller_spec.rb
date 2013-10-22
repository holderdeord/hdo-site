require 'spec_helper'

describe Admin::GovernmentsController do
  context 'user' do
    let(:user) { User.make! role: 'contributor' }
    before { sign_in user }

    it 'can show index' do
      Government.make!(name: 'a', start_date: 8.years.ago, end_date: 4.years.ago )
      Government.make!(name: 'b', start_date: 4.years.ago + 1.day, end_date: 1.day.ago )

      get :index

      assigns(:governments).should == Government.order(:start_date).reverse_order
    end

    it 'can not create a new government' do

    end


    it 'can not update a government'
    it 'can not destory a government'

  end

  context 'admin' do
    let(:user) { User.make! role: 'admin' }
    before { sign_in user }
    let(:government) { Government.make! }

    it 'can create a new government' do
      get :new
      assigns(:government).should be_kind_of(Government)

      response.should be_success
      response.should have_rendered(:new)

      attributes = {
        name: 'gov',
        start_date: 4.years.ago,
        end_date: Date.today
      }

      expect {
        post :create, government: attributes
        response.should redirect_to(admin_governments_path)
      }.to change(Government, :count).by(1)
    end

    it 'can edit a government' do
      get :edit, id: government

      assigns(:government).should == government
      response.should have_rendered(:edit)
    end

    it 'can update a government' do
      put :update, id: government, government: { name: 'foo' }

      assigns(:government).should == government.reload
      government.name.should == 'foo'

      response.should redirect_to admin_governments_path
    end


    it 'can destroy a government' do
      delete :destroy, id: government
      response.should redirect_to admin_governments_path

      Government.count.should be_zero
    end
  end
end
