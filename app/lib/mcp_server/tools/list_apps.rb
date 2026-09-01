# frozen_string_literal: true

module McpServer
  module Tools
    class ListApps < MCP::Tool
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      tool_name "errbit_list_apps"
      description "List Errbit applications, ordered by name."
      annotations read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false
      input_schema(
        properties: {
          page: {type: "integer", minimum: 1},
          per_page: {type: "integer", minimum: 1, maximum: MAX_PER_PAGE}
        }
      )

      class << self
        def call(page: 1, per_page: DEFAULT_PER_PAGE, **)
          apps = App.order_by(name: :asc, _id: :asc).page(page).per(per_page)
          result = {
            apps: apps.map { |app| AppPresenter.summary(app) },
            page: page,
            per_page: per_page,
            total_pages: apps.total_pages,
            total_count: apps.total_count
          }

          ToolResponse.success(result)
        end
      end
    end
  end
end
