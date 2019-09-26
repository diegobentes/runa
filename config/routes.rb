Rails.application.routes.draw do

  get 'folders/search_folders', to: "folders#search_folders"
  get 'folders/search_notes', to: "folders#search_notes"

  resources :notes
  resources :folders

  get 'folders/:previous_id/subfolders', to: "folders#subfolders"
  get 'folders/:id/notes', to: "folders#notes"

  get 'folders/:previous_id/previous_folders', to: "folders#previous_folders"
  get 'folders/:id/previous_notes', to: "folders#previous_notes"

  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
