# frozen_string_literal: true

module Api
  module V1
    class FollowsController < ApiController
      before_action :protected_by_session
      before_action :set_follow, only: %i[destroy increment]
      before_action :protected_by_owner, only: %i[destroy increment]

      def index
        @follows = Follow.where(
          followable_type: params[:followable_type],
          followable_id: params[:followable_id]
        )
      end

      def create
        @follow = Follow.new(follow_params)
        @follow.user = @current_user
        if @follow.save
          render json: @current_user.subscribes_to_a, status: :ok
        else
          render json: { error: @follow.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @follow.delete
          render json: @current_user.subscribes_to_a, status: :ok
        else
          render json: { error: @follow.errors }, status: :unprocessable_entity
        end
      end

      def increment
        @follow.increment!
        render json: {}, status: :ok
      end

      private

      def set_follow
        @follow = @current_user.subscribes.find_by followable_type: params[:followable_type], followable_id: params[:followable_id]
      end

      def follow_params
        params.require(:follow).permit(
          :followable_type,
          :followable_id
        )
      end

      def protected_by_owner
        not_authorized if @current_user.id != @follow.user_id
      end
    end
  end
end
