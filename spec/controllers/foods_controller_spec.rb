require 'rails_helper'

describe FoodsController do
  before :each do
    user = create(:user)
    session[:user_id] = user.id

    @food = create(:food, price: 10000)
  end

  it "includes CurrentCart" do
    expect(LineItemsController.ancestors.include? CurrentCart).to eq(true)
  end
    
  describe 'GET #index' do
    before :each do
      @searched_food1 = create(:food, name: "Ayam Rica-Rica", description: "Ayam", price: 15000)
      @searched_food2 = create(:food, name: "Steak Ayam BBQ", description: "Steak", price: 25000)
      @searched_food3 = create(:food, name: "Nasi Goreng Ayam", description: "Nasi Goreng", price: 35000)
    end

    context 'with params[:letter]' do
      it "populates an array of foods starting with the letter" do
        get :index, params: { letter: 'N' }
        expect(assigns(:foods)).to match_array([@searched_food3])
      end

      it "renders the :index template" do
        get :index, params: { letter: 'N' }
        expect(response).to render_template :index
      end
    end

    context 'without params[:letter]' do
      it "populates an array of all foods" do 
        get :index
        expect(assigns(:foods)).to match_array([@food, @searched_food1, @searched_food2, @searched_food3])
      end

      it "renders the :index template" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'with search parameters' do
      it "can be searched by name" do
        get :index, params: { search: { name_like: 'ayam' } }
        expect(assigns(:foods)).to match_array([@searched_food1, @searched_food2, @searched_food3])
      end

      it "can be searched by description" do
        get :index, params: { search: { description_like: 'ayam' } }
        expect(assigns(:foods)).to match_array([@searched_food1])
      end

      it "can be searched by minimum_price" do
        get :index, params: { search: { minimum_price: 20000 } }
        expect(assigns(:foods)).to match_array([@searched_food2, @searched_food3])
      end

      it "can be searched by maximum_price" do
        get :index, params: { search: { maximum_price: 30000 } }
        expect(assigns(:foods)).to match_array([@food, @searched_food1, @searched_food2])
      end
    end
  end

  describe 'GET #show' do
    it "assigns the requested food to @food" do
      get :show, params: { id: @food }
      expect(assigns(:food)).to eq @food
    end

    it "displays related reviews" do
      review1 = create(:food_review, reviewable: @food)
      review2 = create(:food_review, reviewable: @food)
      get :show, params: { id: @food }
      expect(assigns[:food].reviews).to match_array([review1, review2])
    end

    it "renders the :show template" do
      get :show, params: { id: @food }
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    it "assigns a new Food to @food" do
      get :new
      expect(assigns(:food)).to be_a_new(Food)
    end

    it "renders the :new template" do
      get :new
      expect(:response).to render_template :new
    end
  end

  describe 'GET #edit' do
    it "assigns the requested food to @food" do
      get :edit, params: { id: @food }
      expect(assigns(:food)).to eq @food
    end

    it "renders the :edit template" do
      get :edit, params: { id: @food }
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context "with valid attributes" do
      it "saves the new food in the database" do
        tag1 = create(:tag)
        tag2 = create(:tag)
        category = create(:category)
        restaurant = create(:restaurant)
        
        expect{
          post :create, params: { food: attributes_for(:food, category_id: category.id, restaurant_id: restaurant.id, tag_ids: [tag1.id, tag2.id]) }
        }.to change(Food, :count).by(1)
      end

      it "redirects to foods#show" do
        category = create(:category)
        restaurant = create(:restaurant)
        post :create, params: { food: attributes_for(:food, category_id: category.id, restaurant_id: restaurant.id) }
        expect(response).to redirect_to(food_path(assigns[:food]))
      end
    end

    context "with invalid attributes" do
      it "does not save the new food in the database" do
        expect{
          post :create, params: { food: attributes_for(:invalid_food) }
        }.not_to change(Food, :count)
      end

      it "re-renders the :new template" do
        post :create, params: { food: attributes_for(:invalid_food) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context "with valid attributes" do
      it "locates the requested @food" do
        patch :update, params: { id: @food, food: attributes_for(:food) }
        expect(assigns(:food)).to eq @food
      end

      it "changes @food's attributes" do
        patch :update, params: { id: @food, food: attributes_for(:food, name: 'Nasi Uduk') }
        @food.reload
        expect(@food.name).to eq('Nasi Uduk')
      end

      it "redirects to the food" do
        patch :update, params: { id: @food, food: attributes_for(:food) }
        expect(response).to redirect_to @food
      end
    end

    context "with invalid attributes" do
      it "does not update the food in the database" do
        patch :update, params: { id: @food, food: attributes_for(:food, name: 'Nasi Uduk', description: nil) }
        @food.reload
        expect(@food.name).not_to eq('Nasi Uduk')
      end

      it "re-renders the :edit template" do
        patch :update, params: { id: @food, food: attributes_for(:invalid_food) }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    it "deletes the food from the database" do
      expect{
        delete :destroy, params: { id: @food }
      }.to change(Food, :count).by(-1)
    end

    it "redirects to foods#index" do
      delete :destroy, params: { id: @food }
      expect(response).to redirect_to foods_url
    end
  end
end