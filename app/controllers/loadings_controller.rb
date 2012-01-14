class LoadingsController < ApplicationController

  before_filter :require_login

  def index
    @loadings = Loading.all

    respond_to do |format|
      format.html
      format.json { render json: @loadings }
    end
  end

  def show
    @loading = Loading.find_by_slug!(params[:id])
    @package = @loading.packages.build()
    @container = @loading.containers.build()
    @comment = @loading.comments.build()

    respond_to do |format|
      format.html
      format.json { render json: @loading }
      format.pdf do
        pdf = LoadingPdf.new(@loading)
        send_data pdf.render, filename: "loading_info_#{@loading.reference}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def new

    @position = Position.find_by_slug(params[:position_id]) if params[:position_id]
    unless @position.nil?
       @loading = @position.loadings.build(params[:loading])
       @loading.operation = @position.operation
       @loading.direction = @position.direction
    else
       @loading = current_patron.loadings.build(params[:loading])
       @loading.operation = params[:operation] if params[:operation]
    end

    respond_to do |format|
      format.html
      format.json { render json: @loading }
    end
  end

  def edit
    @loading = Loading.find_by_slug(params[:id])
  end

  def create
    @loading = current_patron.loadings.build(params[:loading])
    @loading.patron_token = current_patron.token
    @loading.user_id = current_user.id

    respond_to do |format|
      if @loading.save
        #current_user.follow(@loading)

        #format.html { redirect_to @loading, notice: 'Loading was successfully created.' }
        format.html { render 'detail', notice: 'Loading was successfully created.' }
        format.json { render json: @loading, status: :created, location: @loading }
      else
        format.html { render action: "new" }
        format.json { render json: @loading.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @loading = Loading.find_by_slug(params[:id])

    respond_to do |format|
      if @loading.update_attributes(params[:loading])
        format.html { redirect_to @loading, notice: 'Loading was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @loading.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @loading = Loading.find_by_slug(params[:id])
    @loading.destroy

    respond_to do |format|
      format.html { redirect_to loadings_url }
      format.json { head :ok }
    end
  end

  def follow
    @loading = Loading.find_by_slug(params[:id])
    current_user.follow(@loading)
  end

  def unfollow
    @loading = Loading.find_by_slug(params[:id])
    current_user.unfollow(@loading)
  end

end
