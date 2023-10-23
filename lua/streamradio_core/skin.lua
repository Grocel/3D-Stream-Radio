local StreamRadioLib = StreamRadioLib

StreamRadioLib.Skin = StreamRadioLib.Skin or {}

local LIB = StreamRadioLib.Skin
table.Empty(LIB)

local _default_json = [[
{
	"children":
	{
		"main":
		{
			"children":
			{
				"browser":
				{
					"children":
					{
						"error":
						{
							"children":
							{
								"textbox":
								{
									"data":
									{
										"color_foreground":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_shadow":
										{
											"r": 40,
											"b": 40,
											"a": 255,
											"g": 40
										},
										"color":
										{
											"r": 128,
											"b": 0,
											"a": 255,
											"g": 32
										}
									},
									"children":
									{
										"scrollbar":
										{
											"children":
											{
												"bar":
												{
													"data":
													{
														"color_foreground_hover":
														{
															"r": 0,
															"b": 0,
															"a": 255,
															"g": 0
														},
														"color_icon_disabled":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color":
														{
															"r": 0,
															"b": 128,
															"a": 255,
															"g": 128
														},
														"color_foreground_disabled":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_hover":
														{
															"r": 150,
															"b": 150,
															"a": 255,
															"g": 150
														},
														"color_icon":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_foreground":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_shadow":
														{
															"r": 40,
															"b": 40,
															"a": 255,
															"g": 40
														},
														"color_disabled":
														{
															"r": 100,
															"b": 100,
															"a": 255,
															"g": 100
														},
														"color_icon_hover":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														}
													}
												},
												"button":
												{
													"data":
													{
														"color_foreground_hover":
														{
															"r": 0,
															"b": 0,
															"a": 255,
															"g": 0
														},
														"color_icon_disabled":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color":
														{
															"r": 0,
															"b": 128,
															"a": 255,
															"g": 128
														},
														"color_foreground_disabled":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_hover":
														{
															"r": 150,
															"b": 150,
															"a": 255,
															"g": 150
														},
														"color_icon":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_foreground":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														},
														"color_shadow":
														{
															"r": 40,
															"b": 40,
															"a": 255,
															"g": 40
														},
														"color_disabled":
														{
															"r": 100,
															"b": 100,
															"a": 255,
															"g": 100
														},
														"color_icon_hover":
														{
															"r": 255,
															"b": 255,
															"a": 255,
															"g": 255
														}
													}
												}
											}
										}
									}
								},
								"button":
								{
									"data":
									{
										"color_foreground_hover":
										{
											"r": 0,
											"b": 0,
											"a": 255,
											"g": 0
										},
										"color_icon_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color":
										{
											"r": 0,
											"b": 128,
											"a": 255,
											"g": 128
										},
										"color_foreground_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_hover":
										{
											"r": 150,
											"b": 150,
											"a": 255,
											"g": 150
										},
										"color_icon":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_foreground":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_shadow":
										{
											"r": 40,
											"b": 40,
											"a": 255,
											"g": 40
										},
										"color_disabled":
										{
											"r": 100,
											"b": 100,
											"a": 255,
											"g": 100
										},
										"color_icon_hover":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										}
									}
								}
							}
						},
						"header":
						{
							"data":
							{
								"color_foreground":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_shadow":
								{
									"r": 40,
									"b": 40,
									"a": 255,
									"g": 40
								},
								"color":
								{
									"r": 0,
									"b": 0,
									"a": 255,
									"g": 100
								}
							}
						},
						"list":
						{
							"children":
							{
								"button":
								{
									"data":
									{
										"color_foreground_hover":
										{
											"r": 0,
											"b": 0,
											"a": 255,
											"g": 0
										},
										"color_icon_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color":
										{
											"r": 0,
											"b": 128,
											"a": 255,
											"g": 128
										},
										"color_foreground_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_hover":
										{
											"r": 150,
											"b": 150,
											"a": 255,
											"g": 150
										},
										"color_icon":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_foreground":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_shadow":
										{
											"r": 40,
											"b": 40,
											"a": 255,
											"g": 40
										},
										"color_disabled":
										{
											"r": 100,
											"b": 100,
											"a": 255,
											"g": 100
										},
										"color_icon_hover":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										}
									}
								},
								"scrollbar":
								{
									"children":
									{
										"bar":
										{
											"data":
											{
												"color_foreground_hover":
												{
													"r": 0,
													"b": 0,
													"a": 255,
													"g": 0
												},
												"color_icon_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color":
												{
													"r": 0,
													"b": 128,
													"a": 255,
													"g": 128
												},
												"color_foreground_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_hover":
												{
													"r": 150,
													"b": 150,
													"a": 255,
													"g": 150
												},
												"color_icon":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_foreground":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_shadow":
												{
													"r": 40,
													"b": 40,
													"a": 255,
													"g": 40
												},
												"color_disabled":
												{
													"r": 100,
													"b": 100,
													"a": 255,
													"g": 100
												},
												"color_icon_hover":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												}
											}
										},
										"button":
										{
											"data":
											{
												"color_foreground_hover":
												{
													"r": 0,
													"b": 0,
													"a": 255,
													"g": 0
												},
												"color_icon_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color":
												{
													"r": 0,
													"b": 128,
													"a": 255,
													"g": 128
												},
												"color_foreground_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_hover":
												{
													"r": 150,
													"b": 150,
													"a": 255,
													"g": 150
												},
												"color_icon":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_foreground":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_shadow":
												{
													"r": 40,
													"b": 40,
													"a": 255,
													"g": 40
												},
												"color_disabled":
												{
													"r": 100,
													"b": 100,
													"a": 255,
													"g": 100
												},
												"color_icon_hover":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												}
											}
										}
									}
								}
							}
						},
						"sidebutton":
						{
							"data":
							{
								"color_foreground_hover":
								{
									"r": 0,
									"b": 0,
									"a": 255,
									"g": 0
								},
								"color_icon_disabled":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color":
								{
									"r": 0,
									"b": 128,
									"a": 255,
									"g": 128
								},
								"color_foreground_disabled":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_hover":
								{
									"r": 150,
									"b": 150,
									"a": 255,
									"g": 150
								},
								"color_icon":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_foreground":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_shadow":
								{
									"r": 40,
									"b": 40,
									"a": 255,
									"g": 40
								},
								"color_disabled":
								{
									"r": 100,
									"b": 100,
									"a": 255,
									"g": 100
								},
								"color_icon_hover":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								}
							}
						}
					}
				},
				"player":
				{
					"children":
					{
						"header":
						{
							"data":
							{
								"color_foreground":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_shadow":
								{
									"r": 40,
									"b": 40,
									"a": 255,
									"g": 40
								},
								"color":
								{
									"r": 0,
									"b": 0,
									"a": 255,
									"g": 100
								}
							}
						},
						"button":
						{
							"data":
							{
								"color_foreground_hover":
								{
									"r": 0,
									"b": 0,
									"a": 255,
									"g": 0
								},
								"color_icon_disabled":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color":
								{
									"r": 0,
									"b": 128,
									"a": 255,
									"g": 128
								},
								"color_foreground_disabled":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_hover":
								{
									"r": 150,
									"b": 150,
									"a": 255,
									"g": 150
								},
								"color_icon":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_foreground":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								},
								"color_shadow":
								{
									"r": 40,
									"b": 40,
									"a": 255,
									"g": 40
								},
								"color_disabled":
								{
									"r": 100,
									"b": 100,
									"a": 255,
									"g": 100
								},
								"color_icon_hover":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								}
							}
						},
						"controls":
						{
							"children":
							{
								"button":
								{
									"data":
									{
										"color_foreground_hover":
										{
											"r": 0,
											"b": 0,
											"a": 255,
											"g": 0
										},
										"color_icon_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color":
										{
											"r": 0,
											"b": 128,
											"a": 255,
											"g": 128
										},
										"color_foreground_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_hover":
										{
											"r": 150,
											"b": 150,
											"a": 255,
											"g": 150
										},
										"color_icon":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_foreground":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_shadow":
										{
											"r": 40,
											"b": 40,
											"a": 255,
											"g": 40
										},
										"color_disabled":
										{
											"r": 100,
											"b": 100,
											"a": 255,
											"g": 100
										},
										"color_icon_hover":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										}
									}
								},
								"progressbar":
								{
									"data":
									{
										"color_foreground_hover":
										{
											"r": 0,
											"b": 0,
											"a": 255,
											"g": 0
										},
										"color_icon_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color":
										{
											"r": 0,
											"b": 128,
											"a": 255,
											"g": 128
										},
										"color_foreground_disabled":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_hover":
										{
											"r": 150,
											"b": 150,
											"a": 255,
											"g": 150
										},
										"color_icon":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_foreground":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										},
										"color_shadow":
										{
											"r": 40,
											"b": 40,
											"a": 255,
											"g": 40
										},
										"color_disabled":
										{
											"r": 100,
											"b": 100,
											"a": 255,
											"g": 100
										},
										"color_icon_hover":
										{
											"r": 255,
											"b": 255,
											"a": 255,
											"g": 255
										}
									}
								}
							}
						},
						"spectrum":
						{
							"children":
							{
								"error":
								{
									"children":
									{
										"textbox":
										{
											"data":
											{
												"color_foreground":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_shadow":
												{
													"r": 40,
													"b": 40,
													"a": 255,
													"g": 40
												},
												"color":
												{
													"r": 128,
													"b": 0,
													"a": 255,
													"g": 32
												}
											},
											"children":
											{
												"scrollbar":
												{
													"children":
													{
														"bar":
														{
															"data":
															{
																"color_foreground_hover":
																{
																	"r": 0,
																	"b": 0,
																	"a": 255,
																	"g": 0
																},
																"color_icon_disabled":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color":
																{
																	"r": 0,
																	"b": 128,
																	"a": 255,
																	"g": 128
																},
																"color_foreground_disabled":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_hover":
																{
																	"r": 150,
																	"b": 150,
																	"a": 255,
																	"g": 150
																},
																"color_icon":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_foreground":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_shadow":
																{
																	"r": 40,
																	"b": 40,
																	"a": 255,
																	"g": 40
																},
																"color_disabled":
																{
																	"r": 100,
																	"b": 100,
																	"a": 255,
																	"g": 100
																},
																"color_icon_hover":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																}
															}
														},
														"button":
														{
															"data":
															{
																"color_foreground_hover":
																{
																	"r": 0,
																	"b": 0,
																	"a": 255,
																	"g": 0
																},
																"color_icon_disabled":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color":
																{
																	"r": 0,
																	"b": 128,
																	"a": 255,
																	"g": 128
																},
																"color_foreground_disabled":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_hover":
																{
																	"r": 150,
																	"b": 150,
																	"a": 255,
																	"g": 150
																},
																"color_icon":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_foreground":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																},
																"color_shadow":
																{
																	"r": 40,
																	"b": 40,
																	"a": 255,
																	"g": 40
																},
																"color_disabled":
																{
																	"r": 100,
																	"b": 100,
																	"a": 255,
																	"g": 100
																},
																"color_icon_hover":
																{
																	"r": 255,
																	"b": 255,
																	"a": 255,
																	"g": 255
																}
															}
														}
													}
												}
											}
										},
										"button":
										{
											"data":
											{
												"color_foreground_hover":
												{
													"r": 0,
													"b": 0,
													"a": 255,
													"g": 0
												},
												"color_icon_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color":
												{
													"r": 0,
													"b": 128,
													"a": 255,
													"g": 128
												},
												"color_foreground_disabled":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_hover":
												{
													"r": 150,
													"b": 150,
													"a": 255,
													"g": 150
												},
												"color_icon":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_foreground":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												},
												"color_shadow":
												{
													"r": 40,
													"b": 40,
													"a": 255,
													"g": 40
												},
												"color_disabled":
												{
													"r": 100,
													"b": 100,
													"a": 255,
													"g": 100
												},
												"color_icon_hover":
												{
													"r": 255,
													"b": 255,
													"a": 255,
													"g": 255
												}
											}
										}
									}
								}
							},
							"data":
							{
								"color_shadow":
								{
									"r": 40,
									"b": 40,
									"a": 255,
									"g": 40
								},
								"color_foreground":
								{
									"r": 192,
									"b": 0,
									"a": 255,
									"g": 0
								},
								"color":
								{
									"r": 64,
									"b": 0,
									"a": 255,
									"g": 32
								},
								"color_icon":
								{
									"r": 255,
									"b": 255,
									"a": 255,
									"g": 255
								}
							}
						}
					}
				}
			},
			"data":
			{
				"color":
				{
					"r": 0,
					"b": 64,
					"a": 255,
					"g": 0
				}
			}
		}
	},
	"data":
	{
		"color_border":
		{
			"r": 0,
			"b": 128,
			"a": 255,
			"g": 64
		},
		"color_cursor":
		{
			"r": 255,
			"b": 255,
			"a": 255,
			"g": 255
		}
	}
}
]]

LIB._default = nil
function LIB.GetDefaultSkin()
	if LIB._default and LIB._default.data then
		return table.Copy(LIB._default)
	end

	LIB._default = StreamRadioLib.JSON.Decode(_default_json or "") or {}
	if not LIB._default.data then
		LIB._default = nil
		error("Default skin is corrupted!")
		return nil
	end

	return table.Copy(LIB._default)
end

return true

