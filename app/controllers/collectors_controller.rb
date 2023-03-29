class CollectorsController < ApplicationController
    def create
        @collector = Collector.new(**buyer_params, account_id: current_account.id)
        authorize @collector
        if @collector.save
          render notice: "Creado exitosamente"
        else
          render 'new', status: :unprocessable_entity
        end
    end
end
