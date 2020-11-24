module Types
    class ComDashboardStatsType < Types::BaseObject
    #   field :id, ID, null: false
    field :city, String, null: true
    field :region, String, null: true
    field :province, String, null: true
    field :geo_usage, Types::IndDashboardStatsType, null: true
    end
end