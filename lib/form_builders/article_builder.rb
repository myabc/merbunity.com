class ArticleFormBuilder < Merb::Helpers::Form::Builder::ResourcefulFormWithErrors
  def initialize(obj, name, origin)
    super
    if (res = obj.class.name.split("::")).pop == "Draft"
      @name = res.join("::").snake_case.split("/").last
    end
  end

end