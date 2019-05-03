module CommonHelper
  def pyonpyon
    'pyonpyon'
  end
end


Itamae::Recipe::EvalContext.include(CommonHelper)
Itamae::Resource::Base::EvalContext.include(CommonHelper)
