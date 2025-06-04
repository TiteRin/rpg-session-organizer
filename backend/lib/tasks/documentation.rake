namespace :docs do
  desc "Update project structure documentation"
  task update_structure: :environment do
    require 'erb'
    
    # Get schema information
    schema = ActiveRecord::Base.connection.tables.map do |table|
      columns = ActiveRecord::Base.connection.columns(table).map do |column|
        {
          name: column.name,
          type: column.type,
          primary: column.name == 'id',
          nullable: column.null
        }
      end
      
      {
        name: table,
        columns: columns
      }
    end

    # Get model information
    models = Dir.glob(Rails.root.join('app/models/*.rb')).map do |file|
      model_name = File.basename(file, '.rb').classify
      model = model_name.constantize rescue nil
      next unless model && model < ApplicationRecord

      {
        name: model_name,
        relationships: model.reflect_on_all_associations.map do |assoc|
          {
            type: assoc.macro,
            name: assoc.name,
            class_name: assoc.class_name
          }
        end
      }
    end.compact

    # Get API routes
    routes = Rails.application.routes.routes.map do |route|
      next unless route.defaults[:controller].to_s.start_with?('api/')
      
      {
        verb: route.verb,
        path: route.path.spec.to_s.gsub('(.:format)', ''),
        controller: route.defaults[:controller],
        action: route.defaults[:action]
      }
    end.compact.uniq

    # Générer la documentation des relations de modèles
    model_relationships_docs = models.map do |model|
      doc = "### #{model[:name]}\n```ruby\nclass #{model[:name]} < ApplicationRecord\n"
      model[:relationships].each do |rel|
        doc += "  #{rel[:type]} :#{rel[:name]}"
        doc += ", class_name: '#{rel[:class_name]}'" if rel[:class_name] != rel[:name].to_s.classify
        doc += "\n"
      end
      doc += "end\n```\n"
      doc
    end.join("\n")

    # Generate documentation
    template = <<~ERB
      # RPG Session Organizer - Project Structure

      ## Database Schema

      <% schema.each do |table| %>
      ### <%= table[:name].classify %>
      <% table[:columns].each do |column| %>
      - `<%= column[:name] %>`: <%= column[:type] %><%= ' (primary key)' if column[:primary] %><%= ' (nullable)' if column[:nullable] %>
      <% end %>

      <% end %>

      ## Model Relationships

      <%= model_relationships_docs %>

      ## API Endpoints

      <% routes.group_by { |r| r[:controller].split('/').last }.each do |controller, controller_routes| %>
      ### <%= controller.classify %>
      <% controller_routes.each do |route| %>
      - <%= route[:verb] %> `<%= route[:path] %>` - <%= route[:action] %>
      <% end %>

      <% end %>
    ERB

    # Write to file
    output_path = Rails.root.join('.', 'docs', 'project_structure.md')
    File.write(output_path, ERB.new(template).result(binding))
    
    puts "Documentation updated at #{output_path}"
  end
end 