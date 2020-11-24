module Types
    class IndDashboardStatsType < Types::BaseObject
    #   field :id, ID, null: false
      field :count, Types::UsageCountType, null: false
      field :usages, Types::TopTenUsagesType, null: true
    end
end