class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    @subscription_ids = []
  end

  def execute(data)
    result = execute_query(data)

    payload = {
      result: result.subscription? ? { data: nil } : result.to_h,
      more: result.subscription?
    }

    @subscription_ids << context[:subscription_id] if result.context[:subscription_id]

    transmit(payload)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    @subscription_ids.each do |sid|
      RecipeSchema.subscriptions.delete_subscription(sid)
    end
  end

  private

  def execute_query(data)
    RecipeSchema.execute(
      query: data["query"],
      context: context,
      variables: data["variables"],
      operation_name: data["operationName"]
    )
  end

  def context
    {
      current_user_id: current_user&.id,
      current_user: current_user,
      channel: self
    }
  end
end
