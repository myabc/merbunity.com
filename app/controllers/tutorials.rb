class Tutorials < Application
  publishable_resource Tutorial
  params_protected :tutorial => [:owner, :owner_id, :published_on, :draft_status]
end
