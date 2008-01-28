require File.join(File.dirname(__FILE__), "../../helper")

with_steps_for :public_access, :markup, :author, :casts, :navigation, :pending_publish do
  run File.expand_path(__FILE__).gsub(".rb",""), :type => MerbStory
end