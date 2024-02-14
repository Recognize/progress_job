module ProgressJob
  class ProgressController < ActionController::Base

    def show
      @delayed_job = Delayed::Job.where(id: params[:job_id]).first
      if @delayed_job.present?
        $redis.set("progress_job:#{@delayed_job.id}", true, ex: 30)
        percentage = !@delayed_job.progress_max.zero? ? @delayed_job.progress_current / @delayed_job.progress_max.to_f * 100 : 0
        render json: @delayed_job.attributes.merge!(percentage: percentage).to_json
      else
        @job = $redis.get("progress_job:#{@delayed_job.id}")
        if @job.present?
          render json: {message: "Job Completed"}, status: 205
        else
          render status: 404
        end
      end
    end

  end
end