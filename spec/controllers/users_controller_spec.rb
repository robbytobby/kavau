require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user_params) {  }
  before(:each){@user = create :admin}
  before(:each){ sign_in @user}

  describe "GET #index" do
    it "assigns all users as @users" do
      get :index
      expect(assigns(:users)).to eq([@user])
    end
  end

  describe "GET #show" do
    it "assigns the requested user as @user" do
      get :show, params: {:id => @user.to_param}
      expect(assigns(:user)).to eq(@user)
    end
  end

  describe "GET #new" do
    it "assigns a new user as @user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET #edit" do
    it "assigns the requested user as @user" do
      get :edit, params: {:id => @user.to_param}
      expect(assigns(:user)).to eq(@user)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, params: {:user => attributes_for(:user)}
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, params: {:user => attributes_for(:user)}
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it "redirects to the created user" do
        post :create, params: {:user => attributes_for(:user)}
        expect(response).to redirect_to(users_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        do_not(:save, User)
        post :create, params: {:user => attributes_for(:user)}
        expect(assigns(:user)).to be_a_new(User)
      end

      it "re-renders the 'new' template" do
        do_not(:save, User)
        post :create, params: {:user => attributes_for(:user)}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes){ {name: 'New Name'} }
    context "with valid params" do
      it "updates the requested user" do
        put :update, params: {:id => @user.to_param, :user => new_attributes}
        @user.reload
        expect(@user.name).to eq('New Name')
      end

      it "updates does not require passwords set" do
        put :update, params: {:id => @user.to_param, :user => new_attributes.merge(password: '', password_confirmation: '')}
        @user.reload
        expect(@user.name).to eq('New Name')
      end

      it "updates does allow updating passwords" do
        old_password = @user.encrypted_password
        put :update, params: {:id => @user.to_param, :user => {password: '1Abcdefg', password_confirmation: '1Abcdefg'}}
        expect(old_password).not_to eq(@user.reload.encrypted_password)
      end

      it "assigns the requested user as @user" do
        put :update, params: {:id => @user.to_param, :user => new_attributes}
        expect(assigns(:user)).to eq(@user)
      end

      it "redirects to the user index" do
        put :update, params: {:id => @user.to_param, :user => new_attributes}
        expect(response).to redirect_to(users_path)
      end
    end

    context "with invalid params" do
      it "assigns the user as @user" do
        do_not(:save, User)
        put :update, params: {:id => @user.to_param, :user => new_attributes}
        expect(assigns(:user)).to eq(@user)
      end

      it "re-renders the 'edit' template" do
        do_not(:save, User)
        put :update, params: {:id => @user.to_param, :user => new_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each){@other_user = create :user}
    it "destroys the requested user" do
      expect {
        delete :destroy, params: {:id => @other_user.to_param}
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      delete :destroy, params: {:id => @other_user.to_param}
      expect(response).to redirect_to(users_url)
    end
  end
end
