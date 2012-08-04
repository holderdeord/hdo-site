require 'spec_helper'

describe FieldsController do

  before :each do
    @user = User.make!
    sign_in @user
  end

  it 'can show index' do
    field = Field.make!

    get :index

    assigns(:fields).should == [field]
    assigns(:topics).should_not be_nil
  end

  it 'can show a field' do
    field = Field.make!

    get :show, id: field

    assigns(:field).should == field
    response.should have_rendered(:show)
  end

  it 'can edit a field' do
    field = Field.make!

    get :edit, id: field

    assigns(:field).should == field
    response.should have_rendered(:edit)
  end

  it 'can update a field' do
    field = Field.make!

    put :update, id: field, field: { name: 'hello' }

    assigns(:field).should == field.reload
    field.name.should == 'hello'

    response.should redirect_to field_path(field)
  end

  it 'can destroy a field' do
    field = Field.make!

    delete :destroy, id: field

    response.should redirect_to fields_path
  end
end
