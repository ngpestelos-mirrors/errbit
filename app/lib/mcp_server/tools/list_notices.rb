# frozen_string_literal: true

module McpServer
  module Tools
    class ListNotices < MCP::Tool
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      tool_name "errbit_list_notices"
      description "List notice summaries for an Errbit problem, newest first."
      annotations read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false
      input_schema(
        properties: {
          problem_id: {type: "string", minLength: 1, maxLength: 100},
          page: {type: "integer", minimum: 1},
          per_page: {type: "integer", minimum: 1, maximum: MAX_PER_PAGE}
        },
        required: ["problem_id"]
      )

      class << self
        def call(problem_id:, page: 1, per_page: DEFAULT_PER_PAGE, **)
          problem = Problem.find(problem_id)
          notices = Notice.for_errs(problem.errs)
            .order_by(created_at: :desc, _id: :desc)
            .page(page)
            .per(per_page)

          ToolResponse.success(result(notices, page, per_page))
        rescue Mongoid::Errors::DocumentNotFound
          ToolResponse.error(error: "problem_not_found", problem_id: problem_id)
        end

        private

        def result(notices, page, per_page)
          {
            notices: notices.map { |notice| NoticePresenter.summary(notice) },
            page: page,
            per_page: per_page,
            total_pages: notices.total_pages,
            total_count: notices.total_count
          }
        end
      end
    end
  end
end
