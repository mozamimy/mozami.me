module RecipeHelper
  def mofmof
    'mofmof'
  end
end

Itamae::Recipe::EvalContext.include(RecipeHelper)
