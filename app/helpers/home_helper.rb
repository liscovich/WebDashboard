module HomeHelper
  def humanize_event(event)
    name, subject = case event.target_type
    when 'Experiment'
      [
        link_to(event.target.name, edit_experiment_path(event.target_parent_id)),
        link_to(I18n.t("object-type.#{event.target_type.underscore}"), edit_experiment_path(event.target_parent_id)),
        nil
      ]
    when 'ExperimentUpload'
      [
        nil,
        link_to(event.target_parent.name, edit_experiment_path(event.target_parent_id))
      ]
    when 'Game'
      [
        link_to(event.target.title, dashboard_game_path(event.target_id)),
        link_to(event.target_parent.name, edit_experiment_path(event.target_parent_id))
      ]
    else
      raise "undefined target_type: #{event.target_type}, event_id: #{event.id}"
    end

    object_type = I18n.t("object-type.#{event.target_type.underscore}")
    namespace   = "#{event.target_type.underscore}-#{event.action}"
    author      = event.author.username # for future implementations: link_to(event.author.username, user_path(event.author))
    
    out = I18n.t("event-type.#{namespace}.title-pattern",
                                  :action  => I18n.t("event-type.#{namespace}.action",  :name => name, :object_type => object_type),
                                  :subject => I18n.t("event-type.#{namespace}.subject", :subject => subject),
                                  :author  => I18n.t("event-type.#{namespace}.author",  :author  => author),
                                  :default => event.action
    )
    out << " #{time_ago_in_words event.created_at} ago"
    out.html_safe
  end
end