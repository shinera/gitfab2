require "spec_helper"

describe RecipeCardsController, type: :controller do
  let(:project){FactoryGirl.create :user_project}
  let(:state){FactoryGirl.build :state}

  subject{response}

  describe "POST create" do
    before do
      xhr :post, :create, owner_name: project.owner.name,
        project_id: project.name, recipe_card: state.attributes
      project.reload
    end
    it{should render_template :create}
    it{expect(project.recipe).to have(1).recipe_cards}
  end

  describe "PATCH update" do
    context "when adding a new derivative card" do
      before do
        card = project.recipe.recipe_cards.create _type: Card::State.name
        xhr :patch, :update, owner_name: project.owner.name,
          project_id: project.name, id: card.id,
          recipe_card: {derivatives_attributes: [{_type: Card::State.name, description: "hoge"}]}
        project.reload
      end
      it{should render_template :update}
      it{expect(project.recipe.recipe_cards.first).to have(1).derivative}
    end

    context "when replacing a state with a derivative state" do
      before do
        card = project.recipe.recipe_cards.create _type: Card::State.name
        card.derivatives.create _type: Card::State.name
        derivative = card.derivatives.create _type: Card::State.name, id: "foo123"
        xhr :patch, :update, owner_name: project.owner.name,
          project_id: project.name, id: card.id,
          recipe_card: {id: derivative.id, derivatives_attributes: [{_type: Card::State.name, description: "hoge"}]}
        project.reload
      end
      it{should render_template :update}
      it{expect(project.recipe.recipe_cards.first.id).to eq "foo123"}
    end
  end
end