module ResourceHelper
  def fuwafuwa
    'fuwafuwa'
  end
end

Itamae::Resource::Base::EvalContext.include(ResourceHelper)
