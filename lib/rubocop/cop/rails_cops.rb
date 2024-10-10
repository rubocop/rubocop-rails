# frozen_string_literal: true

require_relative 'mixin/active_record_helper'
require_relative 'mixin/active_record_migrations_helper'
require_relative 'mixin/class_send_node_helper'
require_relative 'mixin/database_type_resolvable'
require_relative 'mixin/enforce_superclass'
require_relative 'mixin/index_method'
require_relative 'mixin/migrations_helper'
require_relative 'mixin/target_rails_version'

require_relative 'rails/action_controller_flash_before_render'
require_relative 'rails/action_controller_test_case'
require_relative 'rails/action_filter'
require_relative 'rails/action_order'
require_relative 'rails/active_record_aliases'
require_relative 'rails/active_record_callbacks_order'
require_relative 'rails/active_record_override'
require_relative 'rails/active_support_aliases'
require_relative 'rails/active_support_on_load'
require_relative 'rails/add_column_index'
require_relative 'rails/after_commit_override'
require_relative 'rails/application_controller'
require_relative 'rails/application_job'
require_relative 'rails/application_mailer'
require_relative 'rails/application_record'
require_relative 'rails/arel_star'
require_relative 'rails/assert_not'
require_relative 'rails/attribute_default_block_value'
require_relative 'rails/belongs_to'
require_relative 'rails/blank'
require_relative 'rails/bulk_change_table'
require_relative 'rails/compact_blank'
require_relative 'rails/content_tag'
require_relative 'rails/create_table_with_timestamps'
require_relative 'rails/dangerous_column_names'
require_relative 'rails/date'
require_relative 'rails/default_scope'
require_relative 'rails/delegate'
require_relative 'rails/delegate_allow_blank'
require_relative 'rails/deprecated_active_model_errors_methods'
require_relative 'rails/dot_separated_keys'
require_relative 'rails/duplicate_association'
require_relative 'rails/duplicate_scope'
require_relative 'rails/duration_arithmetic'
require_relative 'rails/dynamic_find_by'
require_relative 'rails/eager_evaluation_log_message'
require_relative 'rails/enum_hash'
require_relative 'rails/enum_syntax'
require_relative 'rails/enum_uniqueness'
require_relative 'rails/env'
require_relative 'rails/env_local'
require_relative 'rails/environment_comparison'
require_relative 'rails/environment_variable_access'
require_relative 'rails/exit'
require_relative 'rails/expanded_date_range'
require_relative 'rails/file_path'
require_relative 'rails/find_by'
require_relative 'rails/find_by_id'
require_relative 'rails/find_each'
require_relative 'rails/freeze_time'
require_relative 'rails/has_and_belongs_to_many'
require_relative 'rails/has_many_or_has_one_dependent'
require_relative 'rails/helper_instance_variable'
require_relative 'rails/http_positional_arguments'
require_relative 'rails/http_status'
require_relative 'rails/i18n_lazy_lookup'
require_relative 'rails/i18n_locale_assignment'
require_relative 'rails/i18n_locale_texts'
require_relative 'rails/ignored_columns_assignment'
require_relative 'rails/ignored_skip_action_filter_option'
require_relative 'rails/index_by'
require_relative 'rails/index_with'
require_relative 'rails/inquiry'
require_relative 'rails/inverse_of'
require_relative 'rails/lexically_scoped_action_filter'
require_relative 'rails/link_to_blank'
require_relative 'rails/mailer_name'
require_relative 'rails/match_route'
require_relative 'rails/migration_class_name'
require_relative 'rails/negate_include'
require_relative 'rails/not_null_column'
require_relative 'rails/order_by_id'
require_relative 'rails/output'
require_relative 'rails/output_safety'
require_relative 'rails/pick'
require_relative 'rails/pluck'
require_relative 'rails/pluck_id'
require_relative 'rails/pluck_in_where'
require_relative 'rails/pluralization_grammar'
require_relative 'rails/presence'
require_relative 'rails/present'
require_relative 'rails/rake_environment'
require_relative 'rails/read_write_attribute'
require_relative 'rails/redundant_active_record_all_method'
require_relative 'rails/redundant_allow_nil'
require_relative 'rails/redundant_foreign_key'
require_relative 'rails/redundant_presence_validation_on_belongs_to'
require_relative 'rails/redundant_receiver_in_with_options'
require_relative 'rails/redundant_travel_back'
require_relative 'rails/reflection_class_name'
require_relative 'rails/refute_methods'
require_relative 'rails/relative_date_constant'
require_relative 'rails/render_inline'
require_relative 'rails/render_plain_text'
require_relative 'rails/request_referer'
require_relative 'rails/require_dependency'
require_relative 'rails/response_parsed_body'
require_relative 'rails/reversible_migration'
require_relative 'rails/reversible_migration_method_definition'
require_relative 'rails/root_join_chain'
require_relative 'rails/root_pathname_methods'
require_relative 'rails/root_public_path'
require_relative 'rails/safe_navigation'
require_relative 'rails/safe_navigation_with_blank'
require_relative 'rails/save_bang'
require_relative 'rails/schema_comment'
require_relative 'rails/scope_args'
require_relative 'rails/select_map'
require_relative 'rails/short_i18n'
require_relative 'rails/skips_model_validations'
require_relative 'rails/squished_sql_heredocs'
require_relative 'rails/strip_heredoc'
require_relative 'rails/table_name_assignment'
require_relative 'rails/three_state_boolean_column'
require_relative 'rails/time_zone'
require_relative 'rails/time_zone_assignment'
require_relative 'rails/to_formatted_s'
require_relative 'rails/to_s_with_argument'
require_relative 'rails/top_level_hash_with_indifferent_access'
require_relative 'rails/transaction_exit_statement'
require_relative 'rails/uniq_before_pluck'
require_relative 'rails/unique_validation_without_index'
require_relative 'rails/unknown_env'
require_relative 'rails/unused_ignored_columns'
require_relative 'rails/unused_render_content'
require_relative 'rails/validation'
require_relative 'rails/where_equals'
require_relative 'rails/where_exists'
require_relative 'rails/where_missing'
require_relative 'rails/where_not'
require_relative 'rails/where_not_with_multiple_conditions'
require_relative 'rails/where_range'
