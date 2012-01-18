# Source:
# http://talklikeaduck.denhaven2.com/2011/01/29/automatic-annotation-with-rails-3-with-the-annotate-gem
namespace :db do
  task :migrate do
    unless Rails.env.production?
      require "annotate/annotate_models"
      AnnotateModels.do_annotations(:position_in_class => 'before', :position_in_fixture => 'before')
    end
  end

  namespace :migrate do
    [:up, :down, :reset, :redo].each do |t|
      task t do
        unless Rails.env.production?
          require "annotate/annotate_models"
          AnnotateModels.do_annotations(:position_in_class => 'before', :position_in_fixture => 'before')
        end
      end
    end
  end
end
