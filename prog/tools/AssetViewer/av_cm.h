#pragma once

const int CM_PLUGIN_BASE = 2000;
const int MAX_COMPOSITE_ENTITY_COUNT = 100; // Per hierarchy level.

// MAIN_MENU_CONSTANTS
enum
{
  CM_PLATFORM_COUNT = 10,

  CM_FILE_MENU = 600,
  CM_SAVE_ASSET_BASE,
  CM_SAVE_CUR_ASSET,
  CM_CHECK_ASSET_BASE,
  CM_RELOAD_SHADERS,

  CM_EXPORT,
  CM_PLATFORM_SUBMENU,
  CM_BUILD_RESOURCES = CM_PLATFORM_SUBMENU + CM_PLATFORM_COUNT,
  CM_BUILD_TEXTURES = CM_BUILD_RESOURCES + CM_PLATFORM_COUNT,
  CM_BUILD_ALL = CM_BUILD_TEXTURES + CM_PLATFORM_COUNT,
  CM_BUILD_CLEAR_CACHE = CM_BUILD_ALL + CM_PLATFORM_COUNT,
  CM_BUILD_ALL_PLATFORM_RES = CM_BUILD_CLEAR_CACHE + CM_PLATFORM_COUNT,
  CM_BUILD_ALL_PLATFORM_TEX,
  CM_BUILD_ALL_PLATFORM,
  CM_BUILD_CLEAR_CACHE_ALL,
  CM_EXPORT_ALL_IMPOSTORS,
  CM_EXPORT_IMPOSTORS_CURRENT_PACK,
  CM_EXPORT_CURRENT_IMPOSTOR,
  CM_CLEAR_UNUSED_IMPOSTORS,

  CM_INC_BUILD_CUR_PACK,
  CM_INC_BUILD_GROUP_ADDITIONAL = CM_INC_BUILD_CUR_PACK + CM_PLATFORM_COUNT,
  CM_INC_BUILD_GROUP_PACK = CM_INC_BUILD_GROUP_ADDITIONAL + CM_PLATFORM_COUNT,
  CM_INC_BUILD_RESOURCES = CM_INC_BUILD_GROUP_PACK + CM_PLATFORM_COUNT,
  CM_INC_BUILD_TEXTURES = CM_INC_BUILD_RESOURCES + CM_PLATFORM_COUNT,
  CM_INC_BUILD_RESOURCES_H = CM_INC_BUILD_TEXTURES + CM_PLATFORM_COUNT,
  CM_INC_BUILD_TEXTURES_H = CM_INC_BUILD_RESOURCES_H + CM_PLATFORM_COUNT,
  CM_INC_BUILD_ALL = CM_INC_BUILD_TEXTURES_H + CM_PLATFORM_COUNT,
  CM_INC_BUILD_ALL_H = CM_INC_BUILD_ALL + CM_PLATFORM_COUNT,
  CM_INC_BUILD_ALL_PLATFORM = CM_INC_BUILD_ALL_H + CM_PLATFORM_COUNT,
  CM_INC_BUILD_ALL_PLATFORM_RES,
  CM_INC_BUILD_ALL_PLATFORM_TEX,
  CM_INC_BUILD_ALL_PLATFORM_H,
  CM_INC_BUILD_ALL_PLATFORM_RES_H,
  CM_INC_BUILD_ALL_PLATFORM_TEX_H,
  CM_INC_BUILD_ALL_PLATFORM_CUR_PACK,
  CM_INC_BUILD_CUR_PACK_BQ_HQ_UHQ_PC,
  CM_INC_BUILD_CUR_PACK_TQ_PC,

  CM_COPY_FOLDERPATH,
  CM_COPY_ASSET_FILEPATH,
  CM_COPY_ASSET_PROPS_BLK,
  CM_COPY_ASSET_NAME,
  CM_COPY_LOD_ASSET_PROPS_BLK,
  CM_COPY_FOLDER_ASSETS_PROPS_BLK,
  CM_COPY_FOLDER_LOD_ASSETS_PROPS_BLK,
  CM_SHOW_ASSET_DEPS,
  CM_SHOW_ASSET_REFS,
  CM_SHOW_ASSET_BACK_REFS,
  CM_REVEAL_IN_EXPLORER,
  CM_CREATE_NEW_COMPOSITE_ASSET,

  CM_OPTIONS_SET_ACT_RATE,
  CM_SETTINGS,
  CM_CAMERAS,
  CM_SCREENSHOT,
  CM_RENDER_GEOMETRY,
  CM_COLLISION_PREVIEW,
  CM_AUTO_ZOOM_N_CENTER,
  CM_AUTO_SHOW_COMPOSITE_EDITOR,

  CM_WINDOW,
  CM_LOAD_DEFAULT_LAYOUT,
  CM_LOAD_LAYOUT,
  CM_SAVE_LAYOUT,
  CM_WINDOW_TOOLBAR,
  CM_WINDOW_TREE,
  CM_WINDOW_PPANEL,
  CM_WINDOW_PPANEL_ACCELERATOR,
  CM_WINDOW_VIEWPORT,
  CM_WINDOW_COMPOSITE_EDITOR,

  CM_NEXT_ASSET,
  CM_PREV_ASSET,

  CM_DEBUG_FLUSH,
  CM_DISCARD_ASSET_TEX,

  CM_STATS_SETTINGS_MAIN_SHOW_ASSETS_STATS,
  CM_STATS_SETTINGS_ASSET_STATS_PAGE,
  CM_STATS_SETTINGS_ASSET_STAT_TRIANGLES_RENDERABLE,
  CM_STATS_SETTINGS_ASSET_STAT_TRIANGLES_PHYS,
  CM_STATS_SETTINGS_ASSET_STAT_TRIANGLES_TRACE,
  CM_STATS_SETTINGS_ASSET_STAT_MATERIAL_COUNT,
  CM_STATS_SETTINGS_ASSET_STAT_TEXTURE_COUNT,
  CM_STATS_SETTINGS_ASSET_STAT_CURRENT_LOD,
  CM_STATS_SETTINGS_ASSET_STAT_FIRST = CM_STATS_SETTINGS_ASSET_STAT_TRIANGLES_RENDERABLE,
  CM_STATS_SETTINGS_ASSET_STAT_LAST = CM_STATS_SETTINGS_ASSET_STAT_CURRENT_LOD,
};

enum
{
  ID_COMMON_GRP = 1024,
  ID_NAME,
  ID_RUN_EDIT,

  ID_SPEC_GRP,
  ID_SCRIPT_GRP,

  ID_COMPOSITE_EDITOR_ENTITY_GRP,
  ID_COMPOSITE_EDITOR_ENTITY_SELECTOR,
  ID_COMPOSITE_EDITOR_ENTITY_ACTIONS,
  ID_COMPOSITE_EDITOR_ENTITY_WEIGHT,

  ID_COMPOSITE_EDITOR_ENTITIES_GRP,
  ID_COMPOSITE_EDITOR_ENTITIES_LIMIT_REACHED,
  ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_SELECTOR_FIRST,
  ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_SELECTOR_LAST = ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_SELECTOR_FIRST + MAX_COMPOSITE_ENTITY_COUNT,
  ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_ACTIONS_FIRST,
  ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_ACTIONS_LAST = ID_COMPOSITE_EDITOR_ENTITIES_ENTITY_ACTIONS_FIRST + MAX_COMPOSITE_ENTITY_COUNT,
  ID_COMPOSITE_EDITOR_ENTITIES_WEIGHT_FIRST,
  ID_COMPOSITE_EDITOR_ENTITIES_WEIGHT_LAST = ID_COMPOSITE_EDITOR_ENTITIES_WEIGHT_FIRST + MAX_COMPOSITE_ENTITY_COUNT,
  ID_COMPOSITE_EDITOR_ENTITIES_ADD,

  ID_COMPOSITE_EDITOR_CHILDREN_GRP,
  ID_COMPOSITE_EDITOR_CHILDREN_LIMIT_REACHED,
  ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_SELECTOR_FIRST,
  ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_SELECTOR_LAST =
    ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_SELECTOR_FIRST + MAX_COMPOSITE_ENTITY_COUNT - 1,
  ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_ACTIONS_FIRST,
  ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_ACTIONS_LAST =
    ID_COMPOSITE_EDITOR_CHILDREN_ENTITY_ACTIONS_FIRST + MAX_COMPOSITE_ENTITY_COUNT - 1,
  ID_COMPOSITE_EDITOR_CHILDREN_ADD,

  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_GRP,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_USE_TRANSFORMATION_MATRIX,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_TM_ROTATION,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_TM_LOCATION,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_TM_SCALE,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_ROT_X,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_ROT_Y,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_ROT_Z,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_OFFSET_X,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_OFFSET_Y,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_OFFSET_Z,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_SCALE,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_SCALE_Y,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_PLACE_TYPE,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_ABOVE_HT,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_WARNING_GRP,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_WARNING_LINE1,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_WARNING_LINE2,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_WARNING_LINE3,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_ADD,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_REMOVE,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_COPY,
  ID_COMPOSITE_EDITOR_NODE_PARAMETERS_PASTE,

  ID_COMPOSITE_EDITOR_COMPOSIT_GRP,
  ID_COMPOSITE_EDITOR_COMPOSIT_SAVE_CHANGES,
  ID_COMPOSITE_EDITOR_COMPOSIT_RESET_TO_FILE,

  ID_COMPOSITE_EDITOR_DELETE_NODE,
};