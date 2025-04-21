Rails.configuration.to_prepare do
  Hyrax::Actors::InterpretVisibilityActor.class_eval do
    def create(env)
      if env.attributes.fetch(:source, []).reject(&:blank?).any? && env.attributes[:record_visibility] != "embargo" && env.curation_concern.class != FileSet
        env.attributes.delete(:visibility) if env.attributes.key? :visibility
        env.attributes.delete(:visibility_during_embargo,) if env.attributes.key? :visibility_during_embargo
        env.attributes.delete(:visibility_after_embargo) if env.attributes.key? :visibility_after_embargo
        env.attributes.delete(:embargo_release_date) if env.attributes.key? :embargo_release_date
      end

      intention = Hyrax::Actors::InterpretVisibilityActor::Intention.new(env.attributes)
      
      env.attributes = intention.sanitize_params
      validate(env, intention, env.attributes) && apply_visibility(env, intention) &&
        next_actor.create(env)
    end

    def apply_visibility(env, intention)
      result = apply_lease(env, intention)

      if env.curation_concern.class == FileSet && env.attributes[:visibility].nil?
        result = apply_embargo(env, intention)
      elsif env.curation_concern.class != FileSet && env.attributes[:record_visibility] == "embargo"
        result = apply_embargo(env, intention)
      elsif env.attributes[:record_visibility] != "private"
        env.curation_concern.visibility = env.attributes[:record_visibility] if env.attributes[:record_visibility]
      end

      env.curation_concern.visibility = env.attributes[:visibility] if env.attributes[:visibility]
      result
    end
  end
end
