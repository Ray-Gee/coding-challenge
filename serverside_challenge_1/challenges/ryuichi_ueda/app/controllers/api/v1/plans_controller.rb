# frozen_string_literal: true

module Api
  module V1
    class PlansController < ApplicationController
      include Constants

      before_action :set_params
      before_action :validate_params

      def list
        totals = ProviderService.calculate(@ampere, @usage)
        providers_info = ProviderService.providers_info(@ampere)
        generated_data = generate_data(totals, providers_info)

        render JsonResponse.ok(generated_data)
      end

      private

      def set_params
        @ampere = params[:ampere].to_i
        @usage = params[:usage].to_i
      end

      def validate_params
        validator = Validator.new(@ampere, @usage)
        return if validator.validate

        render JsonResponse.unprocessable_entity(validator.error_message)
        nil
      end

      def generate_data(totals, providers_info)
        providers_info.map do |provider, info|
          {
            provider_name: info.keys.first,
            plan_name: info.values.first,
            price: totals[provider]
          }
        end
      end
    end
  end
end
