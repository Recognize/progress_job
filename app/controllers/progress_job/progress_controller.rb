module ProgressJob
  class ProgressController < ActionController::Base

    def show
      @delayed_job = Delayed::Job.where(id: params[:job_id]).first
      if @delayed_job.present?
        percentage = !@delayed_job.progress_max.zero? ? @delayed_job.progress_current / @delayed_job.progress_max.to_f * 100 : 0
        render json: @delayed_job.attributes.merge!(percentage: percentage).to_json
      else
        @job = $redis.get("progress_job:#{params[:job_id]}")
        if @job.present?
          render json: {message: "Job Completed"}, status: 205
        else
          render json: {message: "Job Not Found"}, status: 404
        end
      end
    end

  end
end