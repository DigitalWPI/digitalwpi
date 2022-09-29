# frozen_string_literal: true

require 'sidekiq/web'
Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'
  # mount BrowseEverything::Engine => '/browse'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
  end

  get '/collections/upub', to: redirect('/collections/k0698b37j')
  get '/collections/cmag', to: redirect('/collections/70795b489')
  get '/collections/yearbook', to: redirect('/collections/vt150n121')
  get '/collections/fpe', to: redirect('/collections/p5547v039')
  get '/collections/ms51', to: redirect('/collections/w0892d411')
  get '/collections/ms54', to: redirect('/collections/3197xp59j')
  get '/collections/ms55', to: redirect('/collections/vx021h564')
  get '/collections/boz', to: redirect('/collections/sq87bv394')
  get '/collections/summits', to: redirect('/collections/b8515q79x')
  get '/collections/theo', to: redirect('/collections/3x816q79g')

  resources :bepress

  get '/bepress/r/:resource_type/:bepress_id', to: 'bepress#record'
  get '/bepress/d/:resource_type/:download_id', to: 'bepress#document'

  devise_for :users, controllers: { omniauth_callbacks: 'callbacks', registrations: "registrations" }
  get 'login' => 'static#login'
  get 'about-page' => 'static#about-page'
  get 'help-page' => 'static#help-page'
  get 'project-centers' => 'static#centers'
  get 'col' => 'static#collections'

  mount Hydra::RoleManagement::Engine => '/'

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => 'sidekiq'
  end

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'
  #match '/pdfviewer/:id', to: 'pdfviewer#index', constraints: { id: /.*/ }, as: 'pdfviewer', via: [:get]
  get '/pdfviewer/:id', to: 'pdfviewer#index', constraints: { id: /[a-z0-9]{9}/ }
  get '/pdfviewer/:id/:parent', to: 'pdfviewer#index', constraints: { id: /[a-z0-9]{9}/ }

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :oai_provider
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  match 'show/:id' => 'common_objects#show', via: :get, as: 'common_object'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
