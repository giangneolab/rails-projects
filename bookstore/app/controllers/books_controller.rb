# == Schema Information
#
# Table name: books
#
#  id             :integer          not null, primary key
#  name           :string
#  about          :text
#  publisher      :string
#  year           :integer
#  isbn           :integer
#  price          :float
#  image          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_new         :integer          default(0)
#  is_best_seller :integer          default(0)
#  original_price :integer
#

class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: [:like, :wishlist]

  before_action :set_current_collect, only: [:like, :wishlist]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
  end

  # Search - using searchkick, a gem based on elasticsearch
  # http://blog.ragnarson.com/2013/10/10/adding-search-and-autocomplete-to-a-rails-app-with-elasticsearch.html
  def search
    @books = Book.search(params[:query])
    respond_to do |format|
      format.html { render :index }
    end
  end

  def autocomplete
    results = Book.search(params[:query], {
                      fields: ["name"],
                      limit: 10,
                      load: false,
                      misspellings: {below: 5}
                  }).map{|b| b.name}

    render json: results
  end

  # GET /books/1
  # GET /books/1.json
  def show
    authors = @book.authors
    @related_books = []
    authors.each do |auth|
      @related_books |= auth.books
    end
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def like
    @book = Book.find(params[:book_id])

    @collection = if current_user.collection
                   current_user.collection
                 else
                   Collection.create(user: current_user)
                 end

    if @collection.books.include? @book
      @collection.books.delete @book
    else
      @collection.books << @book
    end


    respond_to do |format|
      format.js
      format.html
      format.json { render json: { status: :ok } }
    end

  end


  def wishlist
    @books = @collection.books
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:name, :about, :publisher, :year, :isbn, :price, :image)
    end

    def set_current_collect
      @collection = if current_user.collection
                      current_user.collection
                    else
                      Collection.create(user: current_user)
                    end
    end
end
