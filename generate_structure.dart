import 'dart:io';

void main() {
  final projectStructure = {
    'lib': [
      'main.dart',
      'app.dart',
      {
        'features': [
          {
            'land_search': [
              {
                'presentation': [
                  {
                    'pages': [
                      'explorer_dashboard.dart',
                      'land_details_page.dart',
                      'document_search_page.dart'
                    ]
                  },
                  {
                    'widgets': [
                      'land_card.dart',
                      'search_filters.dart',
                      'map_view.dart',
                      'property_details_card.dart',
                      'owner_info_card.dart'
                    ]
                  }
                ]
              },
              {
                'domain': [
                  {
                    'entities': [
                      'land_data.dart',
                      'owner.dart',
                      'site_plan.dart',
                      'gps_point.dart',
                      'bearing_distance.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'land_search_repository.dart'
                    ]
                  },
                  {
                    'usecases': [
                      'get_land_details.dart',
                      'search_lands.dart',
                      'filter_search_results.dart'
                    ]
                  }
                ]
              },
              {
                'data': [
                  {
                    'models': [
                      'land_data_model.dart',
                      'owner_model.dart',
                      'site_plan_model.dart',
                      'gps_point_model.dart',
                      'bearing_distance_model.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'land_search_repository_impl.dart'
                    ]
                  },
                  {
                    'datasources': [
                      'land_search_remote_datasource.dart',
                      'land_search_local_datasource.dart'
                    ]
                  }
                ]
              }
            ]
          },
          {
            'authentication': [
              {
                'presentation': [
                  {
                    'pages': [
                      'login_page.dart',
                      'register_page.dart',
                      'profile_page.dart'
                    ]
                  },
                  {
                    'widgets': [
                      'auth_form.dart',
                      'profile_card.dart'
                    ]
                  }
                ]
              },
              {
                'domain': [
                  {
                    'entities': [
                      'user.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'auth_repository.dart'
                    ]
                  },
                  {
                    'usecases': [
                      'login.dart',
                      'register.dart',
                      'logout.dart'
                    ]
                  }
                ]
              },
              {
                'data': [
                  {
                    'models': [
                      'user_model.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'auth_repository_impl.dart'
                    ]
                  },
                  {
                    'datasources': [
                      'auth_remote_datasource.dart',
                      'auth_local_datasource.dart'
                    ]
                  }
                ]
              }
            ]
          },
          {
            'map_view': [
              {
                'presentation': [
                  {
                    'pages': [
                      'map_view_page.dart'
                    ]
                  },
                  {
                    'widgets': [
                      'map_controls.dart',
                      'property_marker.dart',
                      'boundary_polygon.dart'
                    ]
                  }
                ]
              },
              {
                'domain': [
                  {
                    'entities': [
                      'map_marker.dart',
                      'map_polygon.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'map_repository.dart'
                    ]
                  }
                ]
              },
              {
                'data': [
                  {
                    'models': [
                      'map_marker_model.dart',
                      'map_polygon_model.dart'
                    ]
                  },
                  {
                    'repositories': [
                      'map_repository_impl.dart'
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        'core': [
          {
            'theme': [
              'app_theme.dart',
              'app_colors.dart',
              'app_text_styles.dart',
            ]
          },
          {
            'widgets': [
              'custom_button.dart',
              'custom_text_field.dart',
              'loading_indicator.dart',
              'error_view.dart',
              'success_dialog.dart'
            ]
          },
          {
            'utils': [
              'constants.dart',
              'helpers.dart',
              'validators.dart',
              'date_formatter.dart',
              'location_utils.dart'
            ]
          },
          {
            'network': [
              'api_client.dart',
              'api_endpoints.dart',
              'network_info.dart',
              'interceptors.dart'
            ]
          },
          {
            'error': [
              'exceptions.dart',
              'failures.dart',
              'error_handler.dart'
            ]
          }
        ]
      },
      {
        'di': [
          'injection_container.dart'
        ]
      },
      {
        'config': [
          'routes.dart',
          'environment_config.dart',
          'api_config.dart'
        ]
      }
    ]
  };

  createStructure('lib', projectStructure['lib']);
  print('LandSearch project structure created successfully!');
}

void createStructure(String basePath, dynamic structure) {
  if (structure is List) {
    for (var item in structure) {
      if (item is String) {
        // Create a file
        final file = File('$basePath/$item');
        file.createSync(recursive: true);
        print('Created file: ${file.path}');
      } else if (item is Map) {
        for (var directory in item.keys) {
          // Create a directory
          final dirPath = '$basePath/$directory';
          Directory(dirPath).createSync(recursive: true);
          print('Created directory: $dirPath');
          // Recurse into the directory
          createStructure(dirPath, item[directory]);
        }
      }
    }
  }
}