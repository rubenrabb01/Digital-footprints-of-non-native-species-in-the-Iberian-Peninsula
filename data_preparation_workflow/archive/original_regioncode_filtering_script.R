

################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################### GEO-TAGGED DATASET ######################################################################################################################################################################################### GEO-TAGGED DATASET ######################################################################################################################################################################################### GEO-TAGGED DATASET ###########################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################


final_df_geotagged_1200km_new_locs_espanded <- rbind(final_df_1200km_new_locs_espanded_1,final_df_1200km_new_locs_espanded_2,final_df_1200km_new_locs_espanded_3,final_df_1200km_new_locs_espanded_4,
                                   final_df_1200km_new_locs_espanded_5,final_df_1200km_new_locs_espanded_6)

library(dplyr)

# Remove duplicates by video_id, title, and video_url
final_df_geotagged_dedup_1200km_new_locs_espanded <- final_df_geotagged_1200km_new_locs_espanded %>%
  distinct(video_id, title, video_url, .keep_all = TRUE)

# Check before/after
cat("Original rows:", nrow(final_df_geotagged_1200km_new_locs_espanded), "\n")
cat("Rows after removing duplicates:", nrow(final_df_geotagged_dedup_1200km_new_locs_espanded), "\n")

# Save if needed
write.csv(final_df_geotagged_dedup_1200km_new_locs_espanded, "yt_species_videos_ES_PT_geotagged_dedup_1200km_new_locs_espanded.csv", row.names = FALSE)


################################################################################################### LIST OF SPECIES WITH SCIENTIFIC AND COMMON NAMES ########################################################

library(data.table)

final_df_geotagged_dedup_1200km_new_locs_espanded <- read_csv("yt_species_videos_ES_PT_geotagged_dedup_1200km_new_locs_espanded.csv")

# Your provided list
all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded <- list(
  "Aedes_japonicus" = c(
      "Aedes japonicus",
      "Mosquito del Japón",
      
      "Mosquito Japón",
      "Mosquito del Japon",
      "Mosquito Japon",
      "Mosquito asiático",
      "Mosquito asiatico",
      "Mosquito asiático de los arbustos",
      "Mosquito asiatico de los arbustos"
  ),

  "Apalone_ferox" = c(
      "Apalone ferox",
      "Tortuga de closca tova de Florida",
      "Tortuga closca tova de Florida",
      "Tortuga de caparazón blando de Florida",
      "Tortuga caparazón blando de Florida",
      "Tortuga de caparazon blando de Florida",
      "Tortuga caparazon blando de Florida",
      "Tartaruga americana de caco mole",
      "Tartaruga-americana-de-casco-mole",
      "Tartaruga-de-casco-mole-americana",
      "Tartaruga de caparazón brando da Florida",
      "Tartaruga caparazón brando da Florida"
  ),

  "Amazona_amazonica" = c(
      "Amazona amazonica",
      "Amazona d'ales carbassa",
      "Amazona carbassa",
      "Amazona de as laranxas",
      "Amazona de ás laranxas",
      "Amazona alinaranxa",
      "Amazona d'ales taronja",
      "Amazona taronja",
      "Papagai d'ales carbassa",
      "Lloro d'ales taronges",
      "Lloro taronges",
      "Amazona alinaranja",
      "Papagaio d'asa laranja",
      "Kuritzaká", "Kuritzaka"
  ),

  "Eupsittula_pertinax" = c(
      "Eupsittula pertinax",
      "Aratinga pertinax",
      "Aratinga pertinaz",
      "Aratinga de coroneta blava",
      "Aratinga coroneta blava",
      "Aratinga de cara castaña",
      "Aratinga cara castaña",
      "Aratinga caraparda",
      "Periquito bochecha parda",
      "Periquito de bochechas pardas",
      "Periquito de garganta castanha"
  ),

  "Aphis_illinoisensis" = c(
      "Aphis illinoisensis",
      "Aphis Aphis illinoisensis",
      "Pulgón de la vid",
      "Pulgon de la vid",
      "Pulgão-preto-da-videira",
      "Pulgão preto",
      "Pulgão preto videira"
  ),

  "Spatula_hottentota" = c(
      "Spatula hottentota",
      "Cerceta hotentote",
      "Cerceta de hottentot",
      "Cerceta hottentot",
      "Xarxet hotentot",
      "Cerceta joi",
      "Ànec hotentot",
      "Cerceta hotentote",
      "Ànec hotentot",
      "Cerceta hottentot",
      "Marrequinha bico azul",
      "Marrequinha-de-bico-azul",
      "Zertzeta hotentot"
  ),

  "Barbronia_weberi" = c(
      "Barbronia weberi",
      "Sanguijuela asiática de agua dulce",
      "Sanguijuela asiatica de agua dulce",
      "Sanguijuela asiática agua dulce",
      "Sanguijuela asiatica agua dulce"
  ),

  "Blastopsylla_occidentalis" = c(
      "Blastopsylla occidentalis",
      "Chicharrita del brote",
      "Piojo saltarín del eucalipto",
      "Piojo saltarín del ocalitu"
  ),

  "Chenonetta_jubata" = c(
      "Chenonetta jubata",
      "Pato de crin",
      "Pato de crina",
      "Ànec de crinera",
      "Ànec crinera",
      "Ganso de melena",
      "Ahate kalpardun"

  ),

  "Columbina_talpacoti" = c(
      "Columbina talpacoti",
      "Columbina colorada",
      "Rolinha púrpura",
      "Rolinha corada",
      "Tórtora terrestre rogenca",
      "Tortora terrestre rogenca",
      "Tierrerita"
  ),

  "Corvus_albus" = c(
      "Corvus albus",
      "Bele azpizuri",
      "Bele azpizuria",
      "Cuervo pio",
      "Corb pitblac",
      "Corb pitblanc",
      "Corvo de coleira",
      "Corb pit blanc",
      "Corvo pego",
      "Bele azpizuri",
      "Corb blanc i negre",
      "Corb de pit blanc",
      "Cuervu píu",
      "Corvo-de-barriga-branca",
      "Gralha-seminarista",
      "Cuervu piu",
      "Erroi azpizuri"
  ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis"
  ),

  "Cygnus_melancoryphus" = c(
      "Cygnus melancoryphus",
      "Cigne coll negre",
      "Cisne cuellinegro",
      "Cisne cuello negro",
      "Cigne de coll negre",
      "Cisne de pescuezu prietu",
      "Cisne de pescuezu-prietu",
      "Cisne de pescoço preto",
      "Cisne-de-pescoço-preto",
      "Cisne de pescozo negro",
      "Beltxarga lepabeltz",
      "Beltxarga lepabeltza"
  ),

  "Dryocosmus_kuriphilus" = c(
      "Dryocosmus kuriphilus",
      "Avispilla del castaño",
      "Avispilla asiática del castaño",
      "Avispilla asiatica del castaño",
      "Cinipídeo do castanheiro",
      "Avespa do castiñeiro"
  ),

  "Gobio_occitaniae" = c(
      "Gobio occitaniae",
      "Gobio occitano"
  ),

  "Equisetum_palustre" = c(
      "Equisetum palustre",
      "Cola de caballo de los pantanos",
      "Cola de caballo de pantano",
      "Cavalinha do pântano",
      "Cavalinha do pantano",
      "Equiset palustre"
  ),

  "Graptemys_pseudogeographica" = c(
      "Graptemys pseudogeographica",
      "Testudo_geographica",
      "Emys geographica",
      "Malaclemys georgraphica",
      "Tortuga mapa falsa",
      "Tortuga falsa mapa",
      "Tortuga mapa del Mississipi",
      "Falsa corcunda do Mississippi",
      "Tartaruga falsa-corcunda",
      "Tartaruga corcunda do Mississipi",
      "Tartaruga falsa corcunda do Mississipi"
  ),

  "Grus_canadensis" = c(
      "Grus canadensis",
      "Antigone canadensis",
      "Ardea canadensis",
      "Grulla canadiense",
      "Grua del Canadà",
      "Grua del Canada",
      "Grou-americano",
      "Grou do Canadá",
      "Kurrilo kanadar",
      "Kurrilo kanadarra",
      "Grúa canadiana",
      "Grua canadiana",
      "Grou canadiano",
      "Grus proavus"
  ),


  "Haemorhous_mexicanus" = c(
      "Haemorhous mexicanus",
      "Carpodacus mexicanus",
      "Pinzón mexicano",
      "Pinzon mexicano",
      "Camachuelo mejicano",
      "Camachuelo mexicano",
      "Carpodaco doméstico",
      "Carpodaco domestico",
      "Pintarroxo mexicano",
      "Picaflor mexicanu",
      "Pinsà casolà",
      "Pinsà casola",
      "Pinsa casola",
      "Pinsà mexicà",
      "Pintarroxo caseiro",
      "Pintarroxo do deserto",
      "Burugorri arrunt",
      "Burugorri arrunta"
  ),

  "Haliaeetus_leucocephalus" = c(
      "Haliaeetus leucocephalus",
      "Águila americana",
      "Aguila americana",
      "Pigargo americano",
      "Pigargo cabeza branca",
      "Pigargo cabeza blanca",
      "Pigargo de cabeza blanca",
      "Pigargo de cabeza branca",
      "Aguila de cap blanc",
      "Àguila cap blanc",
      "Àguila de cap blanc",
      "Pigarg americà",
      "Itsas arrano buruzuri",
      "Itsas arrano buruzuria",
      "Arrano buruzuri",
      "Arrano buruzuria",
      "Águia-americana",
      "Águia-de-cabeça-branca",
      "Itsas buruzuri",
      "Itsas buruzuria"
  ),

  "Ictalurus_punctatus" = c(
      "Ictalurus punctatus",
      "Silurus punctatus",
      "Peix gat americà",
      "Pez gato americano",
      "Bagre_americano",
      "Bagre de canal",
      "Bagre del canal",
      "Peixe gato americano",
      "Pez gato punteado",
      "Bagre canal"
  ),

  "Leuciscus_aspius" = c(
      "Leuciscus_aspius",
      "Aspio"
  ),

  "Lorius_chlorocercus" = c(
      "Lorius chlorocercus",
      "Lori acollarado",
      "Lori collar groc",
      "Lori de collar groc",
      "Lóris-de-colar-amarelo",
      "Lóris colar amarelo",
      "Loris de colar amarelo",
      "Loris colar amarelo",
      "Lóri-de-colar-amarelo"
  ),

  "Macrochelys_temminckii" = c(
      "Macrochelys temminckii",
      "Tortuga caimán",
      "Tortuga caiman",
      "Tortuga aligator",
      "Tortuga cocodrilo mordedora",
      "Tartaruga aligátor",
      "Tartaruga aligator",
      "Tartaruga mordedora de cocodrilo"
  ),

  "Maeotias_marginata" = c(
      "Maeotias marginata",
      "Hidromedusa de agua salobre",
      "Hidromedusa agua salobre",
      "Medusa del mar Negro"
  ),

  "Marisa_cornuarietis" = c(
      "Marisa cornuarietis",
      "Caracol cuerno de carnero gigante",
      "Caracol cuerno carnero gigante",
      "Caracol cuerno gigante de borrego",
      "Caracol cuerno gigante borrego",
      "Caracol cuerno de carnero",
      "Caracol cuerno carnero",
      "Caracol cuerno borrego",
      "Caracol colombiano",
      "Caragol banya de carner gegant",
      "Caragol colombià"
  ),

  "Microlepia_platyphylla" = c(
      "Microlepia platyphylla"
  ),

  "Mimus_gilvus" = c(
      "Mimus gilvus",
      "Sinsonte tropical",
      "Sinsont tropical",
      "Mim de sabana",
      "Mim de les sabanes",
      "Imitador tropical",
      "Pájaro imitador tropical",
      "Mirla blanca",
      "Sabiá-da-praia",
      "Sabia da praia",
      "Mimo-tropical",
      "Mimu tropical",
      "Tordo-imitador-da-praia",
      "Zentzuntle tropikal"
  ),

  "Musophaga_violacea" = c(
      "Musophaga violacea",
      "Turaco violáceo",
      "Turaco violaceo",
      "Turac violaci",
      "Turaco violeta",
      "Turacu violaceu",
      "Turako bioleta",
      "Pavão-azul"
  ),

  "Netta_peposaca" = c(
      "Netta peposaca",
      "Pato peposaca",
      "Xibec peposaca",
      "Peposaka ahate",
      "Peposaka ahatea",
      "Zarro patagónico",
      "Parrulo patagónico"
  ),

  "Obolodiplosis_robiniae" = c(
      "Obolodiplosis robiniae",
      "Mosquito de las agallas de la robinia"
  ),

  "Orientogalba viridis" = c(
      "Orientogalba viridis",
      "Austropeplea viridis",
      "Lymnaea viridis",
      "Radix viridis",
      "Austropeplea viridis",
      "Caracol anfibio de agua dulce"
  ),

  "Ommatotriton_ophryticus" = c(
      "Ommatotriton ophryticus",
      "Tritón crestado turco", "Tritón-crestado-turco", "Tritón_crestado_turco",
      "Tritón con bandas del norte", "Tritón_con_bandas_del_norte",
      "Tritón bandas norte", "Tritón_bandas_norte", "Tritón-bandas-norte",
      "Tritão de banda do Norte", "Tritão-de-banda-do-Norte", "Tritão_de_banda_do_Norte",
      "Tritó caucàsic", "Tritó-caucàsic", "Tritó_caucàsic",
      "Triton ophryticus", "Triton_ophryticus",
      "Triturus ophryticus", "Triturus_ophryticus"
  ),

  "Palaemon_macrodactylus" = c(
      "Palaemon macrodactylus",
      "Camarón emigrante", "Camarón-emigrante", "Camarón_emigrante"
  ),

  "Pelodiscus_sinensis" = c(
      "Pelodiscus sinensis",
      "Tortuga china de caparazón blando",
      "Tortuga china de caparazon blando",
      "Tortuga china caparazón blando",
      "Tortuga china caparazon blando",
      "Tortuga china de concha blanda",
      "Galápago de conchablanda chino",
      "Galapago de conchablanda chino",
      "Galápago conchablanda chino",
      "Galápago de concha blanda chino",
      "Galapago de concha blanda chino",
      "Tortuga de caparazón blando china",
      "Tortuga de caparazon blando china",
      "Tartaruga-de-carapaça-mole-chinesa",
      "Tartaruga carapaça mole chinesa",
      "Tortuga de cloca tova xinesa",
      "Tortuga de petxina tova xinesa",
      "Tortuga de cloaca tova xinesa",
      "Tartaruga chinesa de caparazón brando"
  ),

  "Perca_fluviatilis" = c(
      "Perca fluviatilis",
      "Perca río",
      "Perca rio",
      "Perca ríu",
      "Perca riu",
      "Perca de río",
      "Perca de rio",
      "Perca europea",
      "Perca euraiática",
      "Perca euraiatica",
      "Perca de ríu",
      "Perca de riu",
      "Perca común",
      "Perca comun",
      "Perka arrunta",
      "Perka arrunt",
      "Perca europeia"
  ),

  "Phoeniculus_purpureus" = c(
      "Phoeniculus purpureus",
      "Puput dels arbres verd",
      "Abubilla arbórea verde",
      "Abubilla arborea verde",
      "Abubilla verde",
      "Puput dels arbres verda",
      "Puput arbres verda",
      "Puput arbòria verda",
      "Puput arboria verda",
      "Zombeteiro purpúreo",
      "Zombeteiro purpureo",
      "Zombeteiro de bico vermelho"
  ),

  "Platycerium_bifurcatum" = c(
      "Platycerium bifurcatum",
      "Cuerno de alce",
      "Falguera banya",
      "Falguera banya d'ant",
      "Banya d'Ant",
      "Banya de cérvol",
      "Cacho de venado",
      "Cacho venado",
      "Cachovenado",
      "Helecho cuerno",
      "Helecho cuerno de alce",
      "Helecho de ciervo",
      "Helecho ciervo",
      "Helecho cuerno de ciervo",
      "Helecho cuerno de venado",
      "Helecho de alce",
      "Staghorn iratzea"
  ),

  "Pseudemys_concinna" = c(
      "Pseudemys concinna",
      "Tortuga jeroglífico",
      "Tortuga jeroglifico",
      "Tortuga jeroglífica",
      "Tartaruga hieroglífica",
      "Tartaruga hieroglifica",
      "Tortuga hieroglyphica"
  ),

  "Psittacus_erithacus" = c(
      "Psittacus erithacus",
      "Loro yaco",
      "Yaco de cola roja",
      "Yaco cola roja",
      "Loro gris de cola roja",
      "Loro gris cola roja",
      "Loro gris africano",
      "Loro gris africano de cola roja",
      "Lloro gris",
      "Lloro gris cuavermell",
      "Lloro gris cua-roig",
      "Lloro gris africà",
      "Lloro cuavermell",
      "Papagaio-cinzento",
      "Papagaio-do-congo",
      "Loro gris afrikarra",
      "Loru gris africanu"
  ),

  "Psyllaephagus_bliteus" = c(
      "Psyllaephagus bliteus"
  ),

  "Rhodospiza_obsoleta" = c(
      "Rhodospiza obsoleta",
      "Camachuelo desertícola",
      "Camachuelo deserticola",
      "Pinsà rosat del desert",
      "Pinsa rosat del desert",
      "Pinsà del desert",
      "Pinsa del desert",
      "Pimpín do deserto",
      "Pimpin do deserto",
      "Pintarroxo do deserto",
      "Verdilhão do deserto",
      "Verdilhao-do-deserto",
      "Basamortuko txonta"
  ),

  "Sipha_flava" = c(
      "Sipha flava",
      "Pulgón amarillo de la caña de azúcar",
      "Pulgón amarillo de la caña de azucar",
      "Pulgon amarillo de la caña de azucar",
      "Pulgón amarillo de caña de azúcar",
      "Pulgón amarillo de caña de azucar",
      "Pulgon amarillo de caña de azucar",
      "Pulgão-amarelo-da-cana-de-açúcar",
      "Pulgão-amarelo-da-cana-de-açucar",
      "Pulgón amarillo azúcar",
      "Pulgon amarillo azúcar",
      "Pulgon amarillo azucar",
      "Pugó groc de la canya de sucre"
  ),

  "Stenopelmus_rufinasus" = c(
      "Stenopelmus rufinasus"
  ),

  "Styela_plicata" = c(
      "Styela plicata",
      "Patata de mar",
      "Patata de Mer"
  ),

  "Testudo_marginata" = c(
      "Testudo marginata",
      "Tortuga marginada",
      "Tortuga almenada",
      "Dortoka ertz zabal",
      "Dortoka ertz zabala",
      "Tartaruga marginata"
  ),

  "Tockus_deckeni" = c(
      "Tockus deckeni",
      "Toco keniata",
      "Toco de Von der Decken",
      "Toco Von der decken",
      "Calau de von der decken",
      "Calau Decken",
      "Calau de Decken"
  ),

  "Trachemys_emolli" = c(
      "Trachemys emolli",
      "Tortuga nicaragüene",
      "Tortuga nicaraguense",
      "Tortuga escurridiza de Nicaragua",
      "Tartaruga de Nicaragua",
      "Tartaruga da Nicarágua"
  ),

  "Vespa_velutina" = c(
      "Vespa velutina",
      "Avispa asiática",
      "Avispa asiatica",
      "Avispa negra asiática",
      "Avispa negra asiatica",
      "Avispón negro asiático",
      "Avispón negro asiatico",
      "Avispon negro asiático",
      "Avispon negro asiatico",
      "Avispa asiática gigante",
      "Avispa asiatica gigante",
      "Vespa carnissera asiàtica",
      "Vespa carnissera asiatica",
      "Avespa asiática",
      "Avespa asiatica",
      "Vespa asiàtica",
      "Vespa asiatica",
      "Vespão asiático",
      "Vespão asiatico",
      "Vespa carnicera asiàtica",
      "Vespa carnicera asiatica",
      "Avispa asesina",
      "Liztor asiarrra",
      "Liztor asiar",
      "Asiako liztor beltza"
  ),

  "Zenaida_meloda" = c(
      "Zenaida meloda",
      "Zenaida peruana",
      "Tórtora de costa",
      "Paloma cuculina",
      "Rola-do-pacífico"
  ),

  "Lepisiota_capensis" = c(
      "Lepisiota capensis",
      "Hormiga azucarera africana"
  ),

  "Neotoxoptera_formosana" = c(
      "Neotoxoptera formosana",
      "Pulgón de la cebolla",
      "Pulgon de la cebolla",
      "Pulgão da cebola"
  ),

  "Phthorimaea_absoluta" = c(
      "Phthorimaea absoluta",
      "Tuta absoluta",
      "Cogollero del tomate",
      "Gusano minador del tomate",
      "Minador de hojas y tallos de la papa",
      "Minador de la hoja del tomate",
      "Polilla del tomate",
      "Palomilla del tomate",
      "Arna de la tomaca",
      "Arna del tomàquet",
      "Arna del tomaquet",
      "Arna tomàquet",
      "Arna tomaquet",
      "Couza do tomate",
      "Cuc minador del tomaca",
      "Cuc del tomàquet",
      "Cuc del tomaquet",
      "Avelaíña do tomate",
      "Tomatearen sitsa",
      "Traça-do-tomateiro",
      "Traça tomateiro"
  ),

  "Puto_barberi" = c(
      "Puto barberi",
      "Cochinilla blanca de la raíz",
      "Cochinilla blanca de la raiz",
      "Cochinilla del café",
      "Cochinilla del cafe",
      "Cochinilla gigante de Barber",
      "Cochinilla gigante Barber"
  ),

  "Lonchura_oryzivora" = c(
      "Lonchura oryzivora",
      "Capuchino arrocero de Java",
      "Gorrión de Java",
      "Gorrion de Java",
      "Maniquí galtablanc",
      "Maniqui galtablanc",
      "Maniquí de Java",
      "Maniqui de Java",
      "Pardal de java",
      "Pardal de Java",
      "Pardal de Xava",
      "Padda de Java"
  ),

  "Neophema_pulchella" = c(
      "Neophema pulchella",
      "Periquito turquesa"
  ),

  "Camponotus_compressus" = c(
      "Camponotus compressus"
  ),

  "Epidiplosis_filifera" = c(
      "Epidiplosis filifera"
  ),

  "Penthimiola_bella" = c(
      "Penthimiola bella"
  ),

  "Schizoporella_errata" = c(
      "Schizoporella errata"
  ),

  "Stenothoe_georgiana" = c(
      "Stenothoe georgiana"
  ),


  "Hercinothrips_dimidiatus" = c(
      "Hercinothrips dimidiatus"
  ),

  "Hydrocharis_laevigata" = c(
      "Hydrocharis laevigata"
  ),

  "Branta_canadensis" = c(
      "Branta canadensis",
      "Barnacla canadiense",
      "Barnacla canadiense grande",
      "Oca del Canadà",
      "Ganso-do-Canadá",
      "Ganso-do-Canada",
      "Gansu canadianu",
      "Gansu canadiense",
      "Gansu de Canada",
      "Branta kanadar",
      "Branta kanadar handi",
      "Branta kanadarra",
      "Kanadako branta"
  ),

  "Bosmina_coregoni" = c(
      "Bosmina coregoni",
      "Eubosmina coregoni"
  ),

  "Geranoaetus_melanoleucus" = c(
      "Geranoaetus melanoleucus",
      "Águila mora",
      "Águila escudada",
      "Àguila pitnegra",
      "Aguila mora",
      "Aguila escudada",
      "Aguila pitnegra",
      "Águila escudada",
      "Àguila escudada",
      "Águia serrana",
      "Bútio-de-peito-preto",
      "BUtio-de-peito-preto",
      "Zapelatz paparbeltz",
      "Zapelatz paparbeltza"
   ),

  "Geranoaetus_polyosoma" = c(
      "Geranoaetus polyosoma",
      "Busardo dorsirrojo",
      "Aligot tricolor",
      "Bútio-de-dorso-vermelho",
      "Butio-de-dorso-vermelho",
      "Bútio variável",
      "Zapelatz aldakor",
      "Zapelatz aldakorra"
   ),

   "Hypoponera_ergatandria" = c(
      "Hypoponera ergatandria"
   ),

   "Leptoglossus_occidentalis" = c(
      "Leptoglossus occidentalis",
      "Chinche americana del pino",
      "Chinche americana de pino",
      "Chinche americano del pino",
      "Chinche americano de pino",
      "Chinche americana de las piñas",
      "Chinche de las piñas",
      "Xinxa americana del pi",
      "Xinxa americana dels pins",
      "Xinxa americana del pins",
      "Inseto pinheiro americano"
   ),

    "Lobiopa_insularis" = c(
      "Lobiopa insularis"
   ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis",
      "Pulga de agua del norte",
      "Pulga-de-água-do-norte",
      "Pulga-de-Agua-do-norte",
      "Pulga água do norte"
  ),

  "Carassius_gibelio" = c(
      "Carassius gibelio",
      "Carpa prusiana",
      "Carpa prussiana",
      "Carpa prussiana prateada",
      "Carpa-prusiana-prateada",
      "Pimpão cinzento"
  ),

  "Chrysonotomyia_chamaeleon" = c(
      "Chrysonotomyia chamaeleon"
  ),

   "Epitrix_similaris" = c(
      "Epitrix similaris",
      "Pulguilla de la patata",
      "Pulguilla de patata",
      "Pulguilla de la papa",
      "Pulga saltona",
      "Pulguilla saltona"
   ),

   "Glycaspis_brimblecombei" = c(
      "Glycaspis brimblecombei",
      "Psílido del eucalipto rojo",
      "Psílido rojo del eucalipto",
      "PsIlido del eucalipto rojo",
      "PsIlido rojo del eucalipto",
      "Conchuela australiana del eucalipto",
      "Conchuela del eucalipto"
   ),

   "Pezothrips_kellyanus" = c(
      "Pezothrips kellyanus",
      "Trips de los cítricos de Kelly",
      "Trips de los cítricos",
      "Trips de los citricos de Kelly",
      "Trips de los citricos",
      "Trips dels cítrics"
   ),

   "Pomacea_maculata" = c(
      "Pomacea maculata",
      "Pomacea insularum",
      "Caracol manzana gigante",
      "Caracol mazá xigante",
      "Cargol poma tacat",
      "Cargol poma gegant"
   ),

   "Sophonia_orientalis" = c(
      "Sophonia orientalis",
      "Chicharrita asiática de dos manchas",
      "Chicharrita asiatica de dos manchas"
   ),

   "Agapornis_fischeri" = c(
      "Agapornis fischeri",
      "Inseparable de Fischer",
      "Inseparábel de Fischer",
      "Inseparabel de Fischer",
      "Inseparável de fischer",
      "Inseparavel de fischer",
      "Agapornis de Fischer",
      "Inseparável-alaranjado"
   ),

  "Lasius_neglectus" = c(
      "Lasius neglectus",
      "Hormiga invasora de jardines",
      "Hormiga invasora de los jardines",
      "Hormiga de jardín invasora",
      "Formiga invasora de jardins",
      "Formiga invasora dels jardins",
      "Formiga de jardí invasora",
      "Formiga de xardín invasora",
      "Formiga invasora de jardim"
  ),

  "Paratrechina_jaegerskioeldi" = c(
      "Nylanderia jaegerskioeldi",
      "Paratrechina jaegerskioeldi",
      "Prenolepis fulva",
      "Hormiga loca",
      "Formiga boja"
  ),

   "Pheidole_indica" = c(
      "Pheidole indica",
      "Pheidole teneriffana",
      "Hormiga cabezona india"
   ),

   "Pheidole_megacephala" = c(
      "Pheidole megacephala",
      "Hormiga leona",
      "Hormiga africana cabezona",
      "Hormiga cabezona africana",
      "Formiga africana cabezona",
      "Formiga africana de cabeça grande",
      "Formiga africana cabezuda",
      "Formiga cabezuda africana",
      "Hormiga cabezona africana"
   ),

   "Strumigenys_silvestrii" = c(
      "Strumigenys silvestrii"
   ),

   "Mnemiopsis_leidyi" = c(
      "Mnemiopsis leidyi",
      "Medusa bombilla",
      "Ctenóforo americano",
      "Medusa bombeta",
      "Anou de mar"
   ),

    "Anoplolepis_gracilipes" = c(
      "Anoplolepis gracilipes",
      "Hormiga zancona",
      "Hormiga loca amarilla",
      "Hormiga loca amarilla africana",
      "Hormiga loca amarilla de África",
      "Hormiga loca amarilla de Africa",
      "Formiga boja groga",
      "Formiga louca amarela",
      "Formiga tola amarela"
    ),

    "Planorbella_duryi" = c(
      "Planorbella duryi",
      "Helisoma duryi",
      "Planorbis de Florida"
    ),

    "Pseudosuccinea_columella" =c(
      "Pseudosuccinea columella",
      "Caracol americano de los trematodos",
      "Caracol americano de trematodos",
      "Caracol de la duela del hígado"
    ),

    "Pseudodiaptomus_marinus" = c(
      "Pseudodiaptomus marinus"
    ),

    "Faxonius_limosus" = c(
      "Faxonius limosus",
      "Orconectes limosus",
      "Cangrejo de los canales",
      "Cangrejo de río de los canales",
      "Cangrejo río de los canales",
      "Cangrejo de rio de los canales",
      "Cangrejo rio de los canales",
      "Cangrejo de canales",
      "Cranc dels canals",
      "Cranc del riu dels canals"
     ),

     "Primolius_auricollis" = c(
      "Primolius auricollis",
      "Guacamayo acollarado",
      "Guacamaya cuello dorado",
      "Guacamaya de cuello dorado",
      "Maracanã-de-colar",
      "Guacamai colldaurat",
      "Arara-de-colar-dourado"
     ),

     "Hemicypris_barbadensis" = c(
      "Hemicypris barbadensis"
     ),

     "Hemicypris_reticulata" = c(
      "Hemicypris reticulata"
     ),

     "Delottococcus_aberiae" = c(
      "Delottococcus aberiae",
      "Cottonet de les Valls",
      "Cottonet de Valls",
      "Cotonet de les Valls",
      "Cotonet de Valls",
      "Cotonet de Sudáfrica",
      "Cotonet de Sudafrica"
     ),

     "Aratinga_jandaya" = c(
      "Aratinga jandaya",
      "Aratinga jandaia",
      "Cotorra jandaya",
      "Jandaia-verdadeira",
      "Periquitão-nordestino"
      ),

     "Belonochilus_numenius" = c(
      "Belonochilus numenius",
      "Chinche del sicomoro",
      "Chinche del sicómoro",
      "Chinche de la semilla del sicómoro",
      "Chinche de la semilla del sicomoro"
      ),

     "Cereopsis_novaehollandiae" = c(
      "Cereopsis novaehollandiae",
      "Ganso cenizo",
      "Ganso ceniciento",
      "Oca cendrosa",
      "Ganso cinzento australiano",
      "Ganso cinzento",
      "Antzara hauskara"
      ),

     "Brachymyrmex_patagonicus" = c(
      "Brachymyrmex patagonicus",
      "Hormiga rover oscura",
      "Hormiga rover negra"
      ),

     "Brachymyrmex_heeri" = c(
      "Brachymyrmex heeri"
      ),

     "Cardiocondyla_obscurior" = c(
      "Cardiocondyla obscurior"
      ),

     "Blechnum_occidentale" = c(
      "Blechnum occidentale"
      ),

     "Anas_flavirostris" = c(
      "Anas flavirostris",
      "Marreca-pardinha",
      "Marrequinha-de-bico-amarelo",
      "Cerceta barcina",
      "Xarxet becgroc",
      "Zertzeta mokohori"
      ),

     "Vespa_orientalis" = c(
      "Vespa orientalis",
      "Vespa oriental",
      "Avispón oriental",
      "Avispon oriental",
      "Avispa oriental"
      ),

     "Tapinoma_melanocephalum" = c(
      "Tapinoma melanocephalum",
      "Hormiga fantasma",
      "Hormiga boticaria",
      "Formiga fantasma"
      ),

     "Tapinoma_pallipes" = c(
      "Tapinoma pallipes"
      ),

     "Anser_cygnoides" = c(
      "Anser cygnoides",
      "Ánsar cisnal",
      "Ansar cisnal",
      "Oca cigne",
      "ánsar cisne",
      "Ansar cisne",
      "Ganso cisnal",
      "Ganso cisne",
      "Ganso africano",
      "Ganso chinês",
      "Beltxarga antzara"
      ),

    "Balistoides_conspicillum" = c(
     "Balistoides conspicillum",
     "Pez ballesta payaso",
     "Pez ballesta payasu",
     "Peixe ballesta pallaso",
     "Peix ballesta pallasso",
     "Peixe-porco-palhaço",
     "Cangulo palhaço"
     ),

    "Duttaphrynus_melanostictus" = c(
     "Duttaphrynus melanostictus",
     "Sapo común asiático",
     "Sapo comun asiatico",
     "Sapo comun asiático",
     "Sapo común asiatico",
     "Sapo comum asiático",
     "Sapo comum asiatico",
     "Sapu común asiáticu",
     "Gripau comú asiàtic",
     "Gripau comú asiatic",
     "Gripau comu asiàtic"
     ),

    "Varanus_exanthematicus" = c(
     "Varanus exanthematicus",
     "Lacerta exanthematicus",
     "Varanus ocellatus",
     "Varano de sabana",
     "Varano de la sabana",
     "Varano de Bosc",
     "Varano de bosc",
     "Varà de sabana",
     "Varà de Bosc",
     "Varano terrestre africano",
     "Varano das savanas",
     "Monitor de savana",
     "Monitor de la sabana",
     "Monitor de sabana"
     ),

    "Vespa_soror" = c(
     "Vespa soror",
     "Avispón sóror",
     "Avispon sóror",
     "Avispón soror",
     "Avispon soror",
     "Avispón gigante del sur",
     "Avispon gigante del sur",
     "Avispa gigante del sur",
     "Vespa gegant del sud",
     "Avispón xigante do sur",
     "Avispon xigante do sur",
     "Vespa-gigante-do-sul"
     ),

    "Vespa_bicolor" = c(
     "Vespa bicolor",
     "Avispa bicolor",
     "Avispón bicolor",
     "Avispon bicolor",
     "Avispa escudo negro",
     "Avispón de escudo negro",
     "Avispón escudo negro",
     "Avispon de escudo negro",
     "Avispon escudo negro"
    ),

    "Lagocephalus_sceleratus" = c(
     "Lagocephalus sceleratus",
     "Piraña del Mediterráneo",
     "Pez sapo de mejillas plateadas",
     "Pez globo plateado",
     "Peixe-balão sapo-de-bochecha-prateada",
     "Peixe-balão-sapo-de-bochecha-prateada",
     "Peixe-balão prateado",
     "Peixe-balão-prateado",
     "Peixe-sapo de bochechas prateadas"
     ),

    "Zebrasoma_flavescens" = c(
     "Zebrasoma flavescens",
     "Acanthurus flavescens",
     "Pez cirujano amarillo",
     "Navajón velero amarillo",
     "Peix cirurgià groc",
     "Cirurgião-amarelo",
     "Peixe-cirurgião-amarelo"
     ),

   "Trachymela_sloanei" = c(
    "Trachymela sloanei",
    "Escarabajo tortuga australiano",
    "Besouro-tartaruga australiano",
    "Besouro-tartaruga-de-eucalipto",
    "Besouro-tartaruga de eucalipto"
     ),

   "Xylotrechus_chinensis" = c(
    "Xylotrechus chinensis",
    "Escarabajo avispa taladro de las moreras",
    "Escarabajo-avispa taladro de las moreras",
    "Escarabajo perforador de las moreras",
    "Escarabajo-avispa barrenador de las moreras",
    "Escarabat vespa barrinador de les moreres",
    "Escarabat vespa barrinador de moreres",
    "Escarabat-vespa barrinador de moreres",
    "Escarabat barrinador de les moreres",
    "Escarabat-barrinador de les moreres",
    "Escarabat vespa escombrador de les moreres",
    "Escarabat-vespa escombrador de les moreres"
     ),

   "Paracoccus_burnerae" = c(
    "Paracoccus burnerae",
    "Cochinilla de la adelfa"
     ),

   "Macrohomotoma_gladiata" = c(
    "Macrohomotoma gladiata",
    "Psila del ficus",
    "Psil·la del ficus",
    "Psilla del ficus"
     ),

   "Paracaprella_pusilla" = c(
    "Paracaprella pusilla"
     ),

   "Caprella_scaura" = c(
    "Caprella scaura",
    "Gamba esqueleto",
    "Gamba fantasma"
     ),

   "Dyspanopeus_sayi" = c(
    "Dyspanopeus sayi",
    "Cangrejo marino americano",
    "Cranc marí americà",
    "Pequeño cangrejo de barro"
     ),

   "Megabalanus_tintinnabulum" = c(
    "Megabalanus tintinnabulum",
    "Balanus tintinnabulum",
    "Percebe bellota"
     ),

   "Solidobalanus_fallax" = c(
    "Solidobalanus fallax"
     ),

   "Vanellus senegallus" = c(
    "Vanellus senegallus",
    "Avefría senegalesa",
    "Avefría del Senegal",
    "Fredeluga del Senegal",
    "Fredeluga senegalesa",
    "Avefría do Senegal",
    "Abibe carunculado",
    "Abibe carúncula",
    "Abibe caruncula"
     ),

   "Chloephaga_picta" = c(
    "Chloephaga picta",
    "Cauquén común",
    "Cauquen común",
    "Cauquén comun",
    "Cauquen comun",
    "Cauquén magallánico",
    "Cauquén magallanico",
    "Cauquen magallánico",
    "Cauquen magallanico",
    "Oca de Magallanes",
    "Ganso patagónico",
    "Ganso-magalhânico",
    "Ganso magallánico",
    "Ganso de Magallanes",
    "Avutarda magallánica",
    "Avutarda de Magallanes",
    "Magallaesko antzara",
    "Magallanes antzarra"
     ),

   "Acridotheres_ginginianus" = c(
    "Acridotheres ginginianus",
    "Miná ribereño",
    "Minà de ribera",
    "Minà fosc",
    "Mainá ribeiriño",
    "Mainá oscura",
    "Mainà riberenc"
     ),

   "Psilopsiagon_aymara" = c(
    "Psilopsiagon aymara",
    "Catita aimará",
    "Cotorreta encaputxada",
    "Periquito-da-serra",
    "Periquito-aimara"
     ),

   "Elanoides_forficatus" = c(
    "Elanoides forficatus",
    "Elanio tijereta",
    "Esparver cuaforcat",
    "Milà de cua forcada",
    "Elani cuaforcat",
    "Elano mir-buztanduna",
    "Elano miru-buztan",
    "Elano miru buztana",
    "Gabián tesoira",
    "Gavião-tesoura",
    "Falcão-tesoura"
     ),

   "Platalea_ajaja" = c(
    "Platalea ajaja",
    "Espátula rosada",
    "Becplaner rosat",
    "Cullereiro americano",
    "Cullereiro rosa",
    "Colhereiro-americano",
    "Colhereiro-rosado",
    "Mokozabal arrosa"
     ),

   "Caloenas_nicobarica" = c(
    "Caloenas nicobarica",
    "Paloma de Nicobar",
    "Paloma Nicobar",
    "Colom de les illes Nicobar",
    "Colom de les Nicobar",
    "Colom de Nicobar",
    "Pombo-de-nicobar",
    "Pombo Nicobar"
     ),

   "Bycanistes_brevis" = c(
    "Bycanistes brevis",
    "Cálao cariplateado",
    "Calau de galtes argentades",
    "Calau galtaargentat",
    "Calau galtes argentades",
    "Calau-de-faces-prateadas",
    "Calau-de-face-prateada",
    "Calau-faces-prateadas",
    "Calau-face-prateada"
     ),

   "Caracara_plancus" = c(
    "Caracara plancus",
    "Caracara carancho",
    "Carancho meridional",
    "Caracarà crestat meridional",
    "Caracarà crestat",
    "Caracara-de-crista",
    "Carcará-de-poupa",
    "Karakara mottodun"
     ),

   "Theora_lubrica" = c(
    "Theora lubrica"
     ),

   "Atriplex_semilunaris" = c(
    "Atriplex semilunaris"
     ),

   "Pluchea_carolinensis" = c(
    "Pluchea carolinensis",
    "Ciguapate"
     ),

   "Axonopus_fissifolius" = c(
    "Axonopus fissifolius",
    "Hierba de alfombra común",
    "Hierba de alfombra comun",
    "Grama brasilera"
     ),

   "Eucheilota_menoni" = c(
    "Eucheilota menoni"
     ),

   "Branchiomma_bairdi" = c(
    "Branchiomma bairdi"
     ),

   "Perinereis_linea" = c(
    "Perinereis linea"
     ),

   "Perophora_japonica" = c(
    "Perophora japonica",
    "Tunicado del Indopacífico",
    "Tunicado Indopacífico",
    "Tunicado Indo-Pacífico",
    "Tunicado del Indopacifico",
    "Tunicado Indopacifico",
    "Tunicado Indo-Pacifico"
     ),

   "Ensis_leei" = c(
    "Ensis leei",
    "Almeja navaja del Atlántico"
     ),

   "Marginella_glabella" = c(
    "Marginella glabella"
     ),

   "Sus_scrofa_var_domestica_raza_vietnamita" = c(
    "Sus scrofa var. domestica raza vietnamita",
    "Cerdo vietnamita",
    "Porc vietnamita",
    "Porco vietnamita",
    "Vietnamgo txerria"
     ),

   "Ferrissia_californica" = c(
    "Ferrissia californica",
    "Lapa de agua dulce americana",
    "Lapa de água doce americana"
     ),

   "Reticulitermes_flavipes" = c(
    "Reticulitermes flavipes",
    "Termita subterránea oriental",
    "Termita subterranea oriental",
    "Tèrmit subterrània oriental",
    "Termit subterrània oriental",
    "Cupim subterrâneo",
    "Cupim subterraneo"
     ),

   "Acizzia_jamatonica" = c(
    "Acizzia jamatonica",
    "Psila de la albicia",
    "Psilla dell'albizia",
    "Psyla de albizia",
    "Psyla de la albizia"
    ),

   "Acridotheres_cristatellus" = c(
    "Acridotheres cristatellus",
    "Mina moñudu",
    "Minà crestat",
    "Miná crestado",
    "Estornino crestado",
    "Mainá-de-crista",
    "Mainato cristado",
    "Mainá-de-crista",
    "Mainato-de-poupa",
    "Hartxori gangarduna"
    ),

   "Agapornis_nigrigenis" = c(
    "Agapornis nigrigenis",
    "Inseparable cachetón",
    "Inseparable de mejillas negras",
    "Agapornis musubeltza",
    "Agapornis musubeltz",
    "Agapornis galtanegre",
    "Inseparable galtanegre",
    "Agapornis de galtes negres",
    "Inseparable de galtes negres",
    "Inseparável-de-faces-pretas"
    ),

   "Amazona_albifrons" = c(
    "Amazona albifrons",
    "Amazona frentialba",
    "Amazona de front blanc",
    "Papagai frontblanc",
    "Amazona frontblanca",
    "Papagaio-de-testa-branca"
    ),

   "Amazona_farinosa" = c(
    "Amazona farinosa",
    "Papagai farinós",
    "Papagai farinós meridional",
    "Amazona harinosa",
    "Amazona farinosa",
    "Papagaio-moleiro",
    "Amazona farinosa meridional"
    ),

   "Amazona_ochrocephala" = c(
    "Amazona ochrocephala",
    "Amazona de front groc",
    "Amazona frontgroga",
    "Lloro de cap groc",
    "Lloro reial",
    "Lloro de corona groga",
    "Papagai de front gorc",
    "Amazona real",
    "Loro real amazónico",
    "Loro real amazonico",
    "Amazona de cabeza amarela",
    "Papagaio-campeiro",
    "Papagaio-de-coroa-amarela",
    "Amazona buruhoria",
    "Amazona de frente mariella",
    "Amazona frente mariella",
    "Amazona frente amarilla"
    ),

   "Amazonetta_brasiliensis" = c(
    "Amazonetta brasiliensis",
    "Pato brasileño",
    "Ànec del Brasil",
    "Marreca-de-pé-vermelho",
    "Marrequinha-brasileira",
    "Ahate brasildar",
    "Ahate brasildarra",
    "Pato Brasileiro"
    ),

   "Aratinga_leucophthalma" = c(
    "Aratinga leucophthalma",
    "Psittacara leucophthalmus",
    "Aratinga ojiblanca",
    "Cotorra ojiblanca",
    "Aratinga ullblanca",
    "Aratinga d'ulls blancs",
    "Periquitão-d'olho-branco"
    ),

   "Atheta_mucronata" = c(
    "Atheta mucronata"
    ),

   "Bemisia_tabaci" = c(
    "Bemisia tabaci",
    "Aleyrodes tabaci",
    "Mosca blanca",
    "Mosca blanca del tabaco",
    "Mosquita blanca del tabaco",
    "Mosca blanca del algodonero",
    "Mosca-branca",
    "Mosca blanca del tabacu",
    "Mosca-branca-do-tabaco",
    "Mosca blanca del tabac",
    "Mosca-branca da batata-doce"
    ),

   "Bursaphelenchus_xylophilus" = c(
    "Bursaphelenchus xylophilus",
    "Nematodo de la madera del pino",
    "Nematode de la fusta del pi",
    "Nematodo-da-madeira-do-pinheiro",
    "Pinuen nematodoaren gaitza",
    "Nematodo da madeira de piñeiro",
    "Nematodo de la madera de los pinos"
    ),

   "Ceratitis_capitata" = c(
    "Ceratitis capitata",
    "Mosca del Mediterráneo",
    "Mosca mediterránea de la fruta",
    "Mosca del Mediterraneo",
    "Mosca mediterranea de la fruta",
    "Mosca frutera del Mediterráneo",
    "Mosca frutera del Mediterraneo",
    "Mosca-das-frutas do mediterrâneo",
    "Mosca-das-frutas do mediterraneo",
    "Mosca-da-fruta do Mediterrâneo",
    "Mosca-da-fruta do Mediterraneo",
    "Mosca da froita mediterránea",
    "Mosca da froita mediterranea",
    "Mosca-do-mediterrâneo",
    "Mosca-do-mediterraneo",
    "Mosca rajada",
    "Mosca mediterrânica da fruta",
    "Mosca mediterranica da fruta",
    "Mosca mediterrània de la fruita",
    "Mosca mediterrania de la fruita",
    "Mosca mediterrânica de la fruita",
    "Mosca mediterranica de la fruita",
    "Mosca del Mediterrani"
    ),

   "Diadema_antillarum" = c(
    "Diadema antillarum",
    "Erizo de lima",
    "Erizo de mar negro",
    "Erizo de mar de espinas largas",
    "Ourizo de mar de espiñas longas",
    "Ouriço de espinhos longos",
    "Ouriço do mar de espinho longo",
    "Ouriço-do-mar de espinhos longos",
    "Eriçó de mar d'espines llargues",
    "Eriçó Diadema"
    ),

   "Drepanaphis_acerifoliae" = c(
    "Drepanaphis acerifoliae"
    ),

   "Drosophila_suzukii" = c(
    "Drosophila suzukii",
    "Drosófila de alas manchadas",
    "Drosófila de ala manchada",
    "Drosofila de alas manchadas",
    "Drosofila de ala manchada",
    "Mosca del vinagre de alas manchadas",
    "Mosca del vinagre alas manchadas",
    "Mosca-do-vinagre-de-asa-manchada",
    "Drosófila das asas manchadas",
    "Drosofila das asas manchadas",
    "Mosca d’ales tacades"
    ),

   "Eos_squamata" = c(
    "Eos squamata",
    "Lori ventrenegre",
    "Lori collar violeta",
    "Lori escamoso",
    "Lóris de colar violeta",
    "Loris de colar violeta",
    "Lóri-de-pescoço-violeta",
    "Lori-de-pescoço-violeta",
    "Lori de collar violeta",
    "Lori de collaret violeta"
    ),

   "Euplectes_macroura" = c(
    "Euplectes macroura",
    "Obispo dorsiamarillo",
    "Bisbe de dors groc",
    "Teixidor d'espatlles grogues",
    "Bispo-de-dorso-amarelo",
    "Viúva-de-manto-amarelo",
    "Bispo-de-manto-amarelo",
    "Bisbe dorsigroc",
    "Euplekte sorbaldahori",
    "Euplekte sorbaldahoria"
    ),

   "Paratrechina_vividula" = c(
    "Paratrechina vividula"
    ),

   "Pionites_melanocephalus" = c(
    "Pionites melanocephalus",
    "Caique de cabeza negra",
    "Cherlicres",
    "Lloro capnegre",
    "Caique de cap negre",
    "Lorito chirlecrés",
    "Marianinha de cabeça preta",
    "Papagaio-de-barrete-preto"
    ),

   "Poicephalus_crassus" = c(
    "Poicephalus crassus",
    "Lloro niam niam",
    "Lloro niam-niam",
    "Lloro nyam-nyam",
    "Lorito nianiam",
    "Papagaio de niam-niam"
    ),

   "Primolius_maracana" = c(
    "Primolius maracana",
    "Guacamayo maracaná",
    "Guacamayo maracana",
    "Guacamayo de Illiger",
    "Guacamayo de cara afeitada",
    "Guacamayo cara afeitada",
    "Guacamai alablau",
    "Arara d'asa azul",
    "Maracanã-verdadeiro",
    "Arara de Illiger"
    ),

   "Scyphophorus_acupunctatus" = c(
    "Scyphophorus acupunctatus",
    "Picudo del agave",
    "Gorgojo del agave",
    "Picudo negro del agave",
    "Morrut negre",
    "Morrut de l’atzavara",
    "Morrut de les atzavares",
    "Morrut de atzavares",
    "Escaravelho-do-Agave",
    "Gorgulho de agave",
    "Gorgojo do agave"
    ),

   "Thaumastocoris_peregrinus" = c(
    "Thaumastocoris peregrinus",
    "Chinche del eucalipto",
    "Xinxa de l'eucaliptus",
    "Percevejo-do-bronzeamento",
    "Percevejo-bronzeado-do-eucalipto",
    "Percevejo-bronzeado"
    ),

   "Rugulopteryx_okamurae" = c(
    "Rugulopteryx okamurae",
    "Alga asiática",
    "Algas asiáticas",
    "Alga asiatica",
    "Algas asiaticas",
    "Alga invasora asiática",
    "Alga asiática invasora",
    "Alga asiatica invasora"
    ),

   "Halimeda_incrassata" = c(
    "Halimeda incrassata"
    ),

   "Aplidium_accarens" = c(
    "Aplidium accarense"
    ),

   "Epichrysocharis_burwelli" = c(
    "Epichrysocharis burwelli"
    ),

   "Ophelimus_maskelli" = c(
    "Ophelimus maskelli"
    ),

   "Tenellia_adspersa" = c(
    "Tenellia adspersa"
    ),

   "Chrysonephos_lewisii" = c(
    "Chrysonephos lewisii"
    ),

   "Crassula_helmsii" = c(
    "Crassula helmsii",
    "Crásula de agua",
    "Crasula de agua",
    "Crásula acuática",
    "Crásula acuatica",
    "Crasula acuática",
    "Crasula acuatica"
    ),

   "Molgula_manhattensis" = c(
    "Molgula manhattensis",
    "Raïm de (la) mar",
    "Raïm de mar",
    "Raïm marí",
    "Raïm mari"
    ),

   "Paracerceis_sculpta" = c(
    "Paracerceis sculpta",
    "Isópodo esculpido",
    "Isopodo esculpido"
    ),

   "Amathia_verticillata" = c(
    "Amathia verticillata",
    "Briozoo espagueti",
    "Espaguete bryozoo"
    ),

   "Ficopomatus_enigmaticus" = c(
     "Ficopomatus enigmaticus",
     "Poliqueto constructor de arrecifes calcáreos",
     "Poliqueto constructor de arrecifes calcareos",
     "Gusano formador de arrecifes"
    ),

   "Caprella_mutica" = c(
     "Caprella mutica",
     "Camarón esqueleto japonés",
     "Camarón esquelet japonès",
     "Camarón esqueleto xaponés",
     "Camarón esqueleto japones",
     "Camarón esquelet japones",
     "Camarón esqueleto xapones",
     "Camaron esqueleto japonés",
     "Camaron esquelet japonès",
     "Camaron esqueleto xaponés",
     "Camaron esqueleto japones",
     "Camaron esquelet japones",
     "Camaron esqueleto xapones",
     "Camarão esqueleto japonês",
     "Camarão esqueleto japones"
    ),

   "Maize_chlorotic_mottle_virus" = c(
     "Maize chlorotic mottle virus",
     "Virus del moteado clorótico del maíz",
     "Vírus do Mosqueado Clorótico do Milho",
     "Vírus da mancha clorótica do milho",
     "Virus del moteado clorotico del maíz",
     "Vírus do Mosqueado Clorotico do Milho",
     "Vírus da mancha clorotica do milho",
     "Virus del moteado clorótico del maiz",
     "Virus del moteado clorotico del maíz",
     "Virus del moteado clorotico del maiz"
    ),

   "Sweet_potato_virus_C" = c(
     "Sweet potato virus C",
     "Virus C de la batata",
     "Vírus da batata doce C",
     "Vírus C da batata-doce",
     "Vírus C da batata-doce",
     "Vírus da batata-doce"
    ),

   "Synoicus_chinensis" = c(
     "Synoicus chinensis",
     "Codorniz china",
     "Guatlla blava asiàtica",
     "Guatlla blava asiatica",
     "Codorniz chinesa"
    ),

   "Tomato_leaf_curl_New_Delhi_virus" = c(
     "Tomato leaf curl New Delhi virus",
     "Virus del rizado amarillo del tomate de Nueva Delhi",
     "Virus del rizado de la hoja del tomate de Nueva Delhi",
     "Virus del enrollado amarillo del tomate de Nueva Delhi",
     "Virus del rizado del tomate de Nueva Delhi",
     "Virus de Nueva Delhi",
     "Virus de l'arrissat del tomàquet de Nova Delhi",
     "Virus de l'arrissat groc del tomàquet de Nova Delhi",
     "Virus de Nova Delhi",
     "Vírus de onda amarela do tomate de Nova Delhi",
     "Vírus enrolado da folha do tomate Nova Delhi",
     "ToLCNDV"
    ),

   "Tomato_mottle_mosaic_virus" = c(
     "Tomato mottle mosaic virus",
     "Virus del mosaico moteado del tomate",
     "Virus del mosaico del moteado",
     "Virus del moteado leve del tomate"
    ),

   "Phytophthora_citricola" = c(
     "Phytophthora citricola",
     "Aguado en cítricos",
     "Aguado de los cítricos",
     "Aguado cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Podredumbre radicular de cítricos",
     "Podredumbre radicular de los cítricos",
     "Aguado en citricos",
     "Aguado de los citricos",
     "Aguado citricos",
     "Pudrición marrón de los citricos",
     "Podredumbre marrón de los citricos",
     "Podedumbre marrón en los citricos",
     "Podredumbre marrón en citricos",
     "Podredumbre radicular de citricos",
     "Podredumbre radicular de los citricos",
     "Pudrición marron de los cítricos",
     "Podredumbre marron de los cítricos",
     "Podedumbre marron en los cítricos",
     "Podredumbre marron en cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Aigualit dels cítrics"
    ),

   "Rapana_venosa" = c(
     "Rapana venosa",
     "Busano veteado",
     "Buche de rapa",
     "Caracol venoso"
    ),

   "Tritia_mutabilis" = c(
     "Tritia mutabilis",
     "Mugarida lisa",
     "Cornet d’arenal",
     "Margarida llisa",
     "Cargolí Blanc",
     "Cargolí Margarida",
     "Cargoli Blanc",
     "Cargoli Margarida"
    ),

   "Harmonia_axyridis" = c(
     "Harmonia axyridis",
     "Mariquita asiática multicolor",
     "Mariquita asiática",
     "Mariquita arlequín",
     "Marieta asiàtica multicolor",
     "Marieta asiàtica",
     "Marieta arlequí",
     "Xoaniña asiática multicor",
     "Xoaniña asiática",
     "Xoaniña da China",
     "Xoaniña arlequín",
     "Arlekin marigorringoa",
     "Joaninha asiática multicolorida",
     "Joaninha asiática",
     "Mariquita asiatica multicolor",
     "Mariquita asiatica",
     "Mariquita arlequin",
     "Marieta asiatica multicolor",
     "Marieta asiatica",
     "Marieta arlequi",
     "Xoaniña asiatica multicor",
     "Xoaniña asiatica",
     "Xoaniña asiatica",
     "Xoaniña da China",
     "Xoaniña arlequin",
     "Joaninha asiatica multicolorida",
     "Joaninha asiatica",
     "Joaninha arlequim"
    ),

   "Psephotus_haematonotus" = c(
     "Psephotus haematonotus",
     "Rabadilla roja",
     "Periquito de rabadilla roja",
     "Periquito rabadilla roja",
     "Perico dorsirrojo",
     "Perico de rabadilla roja",
     "Perico rabadilla roja",
     "Periquito dorsirrojo",
     "Cotorra de carpó roig",
     "Cotorra de carpo roig",
     "Cotorra de dors roig",
     "Perico carpó-roig",
     "Perico carpo-roig",
     "Periquito-d'uropígio-vermelho"
    ),

   "Pycnonotus_jocosus" = c(
     "Pycnonotus jocosus",
     "Bulbul orfeo",
     "Bulbul de bigoti vermell",
     "Bulbul orfeu",
     "Bulbul de bigot roig",
     "Bulbul de faceiras vermellas",
     "Bulbul de meixelas brancas",
     "Bulbul masailgorri",
     "Bulbul moñuzu",
     "Bulbul-de-faces-vermelhas"
    ),

   "Axonopus_fissifolius" = c(
     "Axonopus fissifolius",
     "Hierba de alfombra común",
     "Hierba de alfombra comun",
     "Grama brasilera"
    ),

   "Pyura_herdmani" = c(
     "Pyura herdmani",
     "Cebo rojo africano"
    ),

   "Cydalima_perspectalis" = c(
     "Cydalima perspectalis",
     "Polilla del boj",
     "Piral del boj",
     "Eruga del boix",
     "Eruga defoliadora del boix",
     "Papallona del boix",
     "Palometa del boix",
     "Avelaíña do buxo",
     "Ezpel sits",
     "Ezpel sitsa"
    ),

   "Megachile_sculpturalis" = c(
     "Megachile sculpturalis",
     "Abeja gigante de la resina",
     "Abeja invasora escultórica",
     "Abeja invasora escultorica",
     "Abella gegant de la resina",
     "Abella xigante de resina"
    ),

   "Wasmannia_auropunctata" = c(
     "Wasmannia auropunctata",
     "Hormiga eléctrica",
     "Hormiga electrica",
     "Hormiguita de fuego",
     "Pequeña hormiga de fuego",
     "Hormiga pequeña de fuego",
     "Formiga de foc roja",
     "Formigueta de foc",
     "Petita formiga de foc",
     "Formiga petita de foc",
     "Formiguiña de lume",
     "Formiga electrica",
     "Formiga elèctrica"
    ),

   "Mauremys_reevesii" = c(
     "Mauremys reevesii",
     "Tortuga china de estanque",
     "Tortuga de estanque china",
     "Tortuga china de tres crestas",
     "Tortuga china crestada",
     "Tortuga crestada china",
     "Tortuga de tres crestas",
     "Galápago chino de tres crestas",
     "Galapago chino de tres crestas",
     "Tortuga d'estany xinesa",
     "Tortuga d'aigua xinesa",
     "Tortuga xinesa de tres quilles",
     "Sapoconcho chinés de tres quillas",
     "Sapoconcho chines de tres quillas",
     "Sapoconcho de tres quillas",
     "Tartaruga-chinesa-de-tres-quillas",
     "Tartaruga de estanque chinesa",
     "Tartaruga chinesa de três quilhas"
    ),

   "Mauremys_sinensis" = c(
     "Mauremys sinensis",
     "Galápago chino de cuello estriado",
     "Tortuga de cuello rayado",
     "Tortuga china de cuello rayado",
     "Tortuga china cuello rayado",
     "Tortuga cuello rayado china",
     "Tortuga cuello rayado",
     "Tortuga de cuello rallado",
     "Tortuga china de cuello rallado",
     "Tortuga de cuello estriado",
     "Tortuga de cuello con franjas",
     "Tortuga Ocadia",
     "Tortuga de coll ratllat",
     "Tortuga xinesa de coll ratllat",
     "Sapoconcho de pescozo listado",
     "Tartaruga de pescozo con franxas",
     "Tartaruga-chinesa-de-pescoço-listado",
     "Tartaruga chinesa de pescoço listrado",
     "Tartaruga-de-pescoço-listrado-chinesa",
     "Tartaruga chinesa de pescoço às riscas"
    ),

   "Ludwigia_peploides" = c(
     "Ludwigia peploides",
     "Duraznillo de agua",
     "Onagraria",
     "Enramada de las tarariras"
    ),

   "Pseudemys_peninsularis" = c(
     "Pseudemys peninsularis",
     "Tortuga de la península",
     "Galápago peninsular",
     "Tortuga de la peninsula",
     "Galapago peninsular"
    ),

   "Spodoptera_frugiperda" = c(
     "Spodoptera frugiperda",
     "Gusano cogollero",
     "Cogollero del maíz",
     "Gusano cogollero del maíz",
     "Oruga cogollera del maíz",
     "Oruga militar tardía",
     "Cogollero del maiz",
     "Gusano cogollero del maiz",
     "Oruga cogollera del maiz",
     "Oruga militar tardia",
     "Cuc cogoller",
     "Oruga militar tardana",
     "Verme-cogollero-do-millo",
     "Lagarta-do-cartucho"
    ),

   "Halyomorpha_halys" = c(
     "Halyomorpha halys",
     "Chinche parda marmorada",
     "Chinche hedionda marrón marmoleada",
     "Chinche apestosa marrón marmolada",
     "Chinche apestoso marrón mármol",
     "Chinche apestoso marron mármol",
     "Chinche apestosa marrón",
     "Chinche apestoso marrón",
     "Chinche hedionda marron marmoleada",
     "Chinche apestosa marron marmolada",
     "Chinche apestoso marron mármol",
     "Chinche apestoso marron marmol",
     "Chinche apestosa marron",
     "Chinche apestoso marron",
     "Chinche apestosa",
     "Chinche hedionda",
     "Bernat marbrejat",
     "Bernat marbrat marró",
     "Bernat marbrat marro",
     "Armarri zimitz jaspeztatua",
     "Zimitz kirasdun marroia",
     "Percevejo marrom marmoreado",
     "Percevejo-asiático",
     "Percevejo-asiatico",
     "Percevejo-fedorento marrom marmorizado"
    ),

   "Aedes_aegypti" = c(
     "Aedes aegypti",
     "Mosquito del dengue",
     "Mosquito momia",
     "Mosquito de la fiebre amarilla",
     "Mosquito africano de la fiebre amarilla",
     "Mosquit del dengue",
     "Mosquit de la febre groga",
     "Mosquito da dengue",
     "Sukar horiaren eltxoak",
     "Mosquito da dengue",
     "Pernilongo rajado"
    ),

   "Euwallacea_fornicatus" = c(
     "Euwallacea fornicatus",
     "Barrenador polígafo",
     "Barrenillo del té",
     "Escarabajo barrenillo del té",
     "Escarabajo barrenador polígafo",
     "Broca-de-tiro-do-chá",
     "Broca-de-tiro-polífaga",
     "Barrenador poligafo",
     "Barrenillo del te",
     "Escarabajo barrenillo del te",
     "Escarabajo barrenador poligafo",
     "Broca-de-tiro-do-cha",
     "Broca-de-tiro-polifaga"
    ),

   "Procambarus_virginalis" = c(
     "Procambarus virginalis",
     "Cangrejo mármol",
     "Cangrejo de mármol",
     "Cangrejo marmol",
     "Cangrejo de marmol",
     "Cangrejo marmoleado",
     "Marmorkrebs"
    ),

   "Cherax_quadricarinatus" = c(
     "Cherax quadricarinatus",
     "Langosta australiana azul",
     "Langosta de agua dulce",
     "Langosta de agua dulce australiana",
     "Langosta de agua dulce de pinzas rojas",
     "Langosta azul",
     "Langosta de río australiana",
     "Langosta de rio australiana",
     "Langosta azul australiana",
     "Yabby azul",
     "Llagosta blava",
     "Llagosta blava australiana",
     "Llagosta autraliana d'aigua dolça",
     "Llagosta d'aigua dolça australiana",
     "Lagosta azul australiana",
     "Lagosta de água doce",
     "Lagosta de água doce australiana",
     "Lagosta de agua doce",
     "Lagosta de agua doce australiana"
    ),

   "Xylella_fastidiosa" = c(
     "Xylella fastidiosa",
     "Xilel la",
     "Xilel·la"
    ),

   "Tobamovirus_fructirugosum" = c(
     "Tobamovirus fructirugosum",
     "Virus del fruto rugoso marrón del tomate",
     "Virus del fruto rugoso marron del tomate",
     "Virus rugoso del tomate",
     "Virus del fruto pardo y rugoso del tomate"
    )

)



# Assuming your list is named all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded

# Extract names and replace underscores with spaces
species_names <- names(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded)
species_names_clean <- gsub("_", " ", species_names)

# View the cleaned species names
print(species_names_clean)

# Optionally, save as a data frame
species_df <- data.frame(Species = species_names_clean)

# If you want to export to CSV
# write.csv(species_df, "species_searched.csv", row.names = FALSE)


########################################################################### PREPARE THE DATASET (MATCHES OF SEARCH TERMS WITH ALL SP NAMES ##################################################################

library(data.table)
library(stringi) # For text normalization

# Function to normalize text (remove accents and convert to lowercase)
normalize_text <- function(text) {
  stri_trans_general(stri_trim(text), "Latin-ASCII") # Convert accents to ASCII equivalent
}

# Convert dataset_geotag_1200km_new_locs_espanded to data.table if not already
setDT(final_df_geotagged_dedup_1200km_new_locs_espanded)



# === Step 1: Create Lookup Table from `all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded` ===
lookup_table <- data.table(
  common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name = unlist(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded, use.names = FALSE),
  unique_species = rep(names(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded), times = sapply(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded, length))
)

# Normalize text in lookup table
lookup_table[, common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name := normalize_text(common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name)]

# Remove duplicates to avoid multiple mappings
lookup_table <- unique(lookup_table, by = "common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name")

# === Step 2: Normalize Species Names in the Main Dataset ===
final_df_geotagged_dedup_1200km_new_locs_espanded[, query := normalize_text(query)]

# Ensure both columns are characters (avoiding potential factor issues)
lookup_table[, common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name := as.character(common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name)]
final_df_geotagged_dedup_1200km_new_locs_espanded[, query := as.character(query)]


# === Step 3: Perform the Merge ===
final_df_geotagged_dedup_1200km_new_locs_espanded <- merge(
  final_df_geotagged_dedup_1200km_new_locs_espanded,
  lookup_table,
  by.x = "query",
  by.y = "common_NEW_ES_PT_geotag_1200km_new_locs_espanded_name",
  all.x = TRUE,
  allow.cartesian = TRUE
)


unique(final_df_geotagged_dedup_1200km_new_locs_espanded$unique_species)


# Ensure your dataset_geotag_1200km_new_locs_espanded is a data.table
setDT(final_df_geotagged_dedup_1200km_new_locs_espanded)

# Count number of rows (videos) per unique_species
species_counts_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- final_df_geotagged_dedup_1200km_new_locs_espanded[, .N, by = unique_species][order(-N)]

# View top species by video count
print(species_counts_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

         unique_species     N
                                      <char> <int>
 1:                           Vespa_velutina    67
 2:                      Psittacus_erithacus    24
 3:                           Bemisia_tabaci    21
 4:                    Rugulopteryx_okamurae    13
 5:                     Phthorimaea_absoluta    10
 6:                       Ceratitis_capitata     7
 7: Sus_scrofa_var_domestica_raza_vietnamita     7
 8:                       Lonchura_oryzivora     7
 9:                        Perca_fluviatilis     7
10:                       Synoicus_chinensis     6
11:                   Platycerium_bifurcatum     6
12:                       Xylella_fastidiosa     6
13:                    Cydalima_perspectalis     5
14:                Leptoglossus_occidentalis     5
15:                       Agapornis_fischeri     4
16:                 Haliaeetus_leucocephalus     4
17:                   Cherax_quadricarinatus     4
18:                           Platalea_ajaja     4
19:                            Rapana_venosa     4
20:                   Macrochelys_temminckii     4
21:                            Aedes_aegypti     3
22:                         Vespa_orientalis     3
23:                    Dryocosmus_kuriphilus     3
24:                     Cygnus_melancoryphus     3
25:              Paratrechina_jaegerskioeldi     3
26:                     Zebrasoma_flavescens     3
27:                        Testudo_marginata     3
28:                     Agapornis_nigrigenis     2
29:                          Anser_cygnoides     2
30:                         Aratinga_jandaya     2
31:                        Halyomorpha_halys     2
32:                             Corvus_albus     2
33:              Graptemys_pseudogeographica     2
34:                  Tapinoma_melanocephalum     2
35:                        Mnemiopsis_leidyi     2
36:                       Musophaga_violacea     2
37:                Scyphophorus_acupunctatus     2
38:                Acridotheres_cristatellus     1
39:                         Leuciscus_aspius     1
40:                        Branta_canadensis     1
41:               Bursaphelenchus_xylophilus     1
42:                        Bycanistes_brevis     1
43:                      Caloenas_nicobarica     1
44:                    Delottococcus_aberiae     1
45:                       Drosophila_suzukii     1
46:                       Equisetum_palustre     1
47:                          Caprella_scaura     1
48:                     Haemorhous_mexicanus     1
49:                    Phoeniculus_purpureus     1
50:                   Psephotus_haematonotus     1
51:                  Reticulitermes_flavipes     1
52:         Tomato_leaf_curl_New_Delhi_virus     1
53:                        Mauremys_sinensis     1
54:                       Trachymela_sloanei     1
55:                      Vanellus senegallus     1
56:                Tobamovirus_fructirugosum     1
                              unique_species     N

--------------################ DATASET WITH SPECIES WITH 0 SEARCH RESULTS ###############

# ? All species you searched for (from your lookup list)
all_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- names(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded)

# ? Species actually matched in the YouTube results
included_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- unique(final_df_geotagged_dedup_1200km_new_locs_espanded$unique_species)

# ? Find species that were NOT included (i.e., no search results)
missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- setdiff(all_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded, included_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

# ? View the missing species
missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded

# Normalize function (like before)
normalize_text <- function(text) stri_trans_general(stri_trim(text), "Latin-ASCII")

# Normalize search terms in the combined dataset_geotag_1200km_new_locs_espanded
final_df_geotagged_dedup_1200km_new_locs_espanded$query_normalized <- normalize_text(final_df_geotagged_dedup_1200km_new_locs_espanded$query)

# Normalize the scientific names (remove underscores and lowercase)
normalized_missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- tolower(gsub("_", " ", missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded))
normalized_missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- normalize_text(normalized_missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

# Check which species DO appear in query
matching_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- unique(
  final_df_geotagged_dedup_1200km_new_locs_espanded$query_normalized[
    final_df_geotagged_dedup_1200km_new_locs_espanded$query_normalized %in% normalized_missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded
  ]
)

# View results
cat("? These missing species WERE found in 'final_df_geotagged_dedup_1200km_new_locs_espanded':\n")
print(matching_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

# Optionally, show which were truly missing
truly_missing_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- setdiff(normalized_missing_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded, matching_species_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

cat("\n? These species are completely absent (not even searched):\n")
print(truly_missing_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)


# Add the "created_at" column as a copy of "published"
final_df_geotagged_dedup_1200km_new_locs_espanded <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
  mutate(created_at = publishedAt)

# Verify the new column is added and matches the "published" column
head(final_df_geotagged_dedup_1200km_new_locs_espanded[, c("publishedAt", "created_at")])


final_df_geotagged_dedup_1200km_new_locs_espanded <- as.data.table(final_df_geotagged_dedup_1200km_new_locs_espanded)
#subset_Aedes_japonicus <- youtube_recent_all_post[youtube_recent_all_post$species_name == "Aedes japonicus",]

# Get unique species names
unique_species <- unique(final_df_geotagged_dedup_1200km_new_locs_espanded$unique_species)

# Rename 'unique_species' to 'TaxonName' in final_df_geotagged_dedup_1200km_new_locs_espanded
final_df_geotagged_dedup_1200km_new_locs_espanded <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
  rename(TaxonName = unique_species)


####################################################################################### ADDING FIRST ZENODO INFORMATION TO THE FORMATTED DATASET ###########################################################

# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(cld2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)
library(officer)


# Read the Excel file
zenodo_sp_list <- read_excel("Recent_Intros_IP_All_for_table_v31_SP_NAMES_UPDATED_cleaned_rev_loc_filters.xlsx")

# Step 1: Clean LifeForm names
zenodo_sp_list <- zenodo_sp_list %>%
  mutate(
    LifeForm = as.character(LifeForm),
    LifeForm = recode(LifeForm,
      "Invertebrates (excl. Arthropods, Molluscs)" = "Non-arthropod invertebrates"
    )
  )

# Step 2: Replace NA in PresentStatus with "uncertain"
zenodo_sp_list$PresentStatus[is.na(zenodo_sp_list$PresentStatus)] <- "uncertain"

# Step 3: Group taxa categories
zenodo_grouped <- zenodo_sp_list %>%
  mutate(
    LifeForm = case_when(
      LifeForm %in% c("Vascular plants", "Algae", "Bryozoa") ~ "Plants",
      LifeForm %in% c("Molluscs") ~ "Non-arthropod invertebrates",
      LifeForm %in% c("Amphibians", "Reptiles") ~ "Herptiles",
      LifeForm %in% c("Viruses","Fungi") ~ "Bacteria, Viruses, Fungi",
      TRUE ~ LifeForm
    )
  ) %>%
  filter(LifeForm != "Mammals")  # Remove group with only 1 species

# Step 4: Summarise unique species
summary_table_geotag_1200km_new_locs_espanded <- zenodo_grouped %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(
    names_from = PresentStatus,
    values_from = n_species,
    values_fill = 0
  )

# Step 5: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% colnames(summary_table_geotag_1200km_new_locs_espanded)) {
    summary_table_geotag_1200km_new_locs_espanded[[col]] <- 0
  }
}

# Step 6: Add totals
summary_table_geotag_1200km_new_locs_espanded <- summary_table_geotag_1200km_new_locs_espanded %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 7: Add total row
total_row <- summary_table_geotag_1200km_new_locs_espanded %>%
  summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = sum(percentage)
  )

summary_table_geotag_1200km_new_locs_espanded_final <- bind_rows(summary_table_geotag_1200km_new_locs_espanded, total_row) %>%
  arrange(desc(total_species))

# Step 8: Export to CSV
write.csv(summary_table_geotag_1200km_new_locs_espanded_final, "summary_species_by_lifeform_with_total_geotag_1200km_new_locs_espanded.csv", row.names = FALSE)

# Step 9: Export to Word (DOCX)
ft <- summary_table_geotag_1200km_new_locs_espanded_final %>%
  flextable() %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

read_docx() %>%
  body_add_par("Summary of Species per Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(ft) %>%
  print(target = "summary_species_by_lifeform_with_total.docx")



# Define the priority order of PresentStatus
status_priority <- c("alien", "established", "casual", "uncertain")

# Convert PresentStatus to a factor with ordered levels
zenodo_cleaned <- zenodo_grouped %>%
  mutate(PresentStatus = factor(PresentStatus, levels = status_priority, ordered = TRUE))

# Apply filtering
zenodo_filtered <- zenodo_cleaned %>%
  group_by(TaxonName) %>%
  filter(FirstRecord == min(FirstRecord)) %>%   # Keep only rows with the minimum year
  slice_min(PresentStatus, with_ties = FALSE) %>% # Break ties using PresentStatus priority
  ungroup()

# View result
print(zenodo_filtered)


# 1. Fix TaxonName formatting + Region in zenodo_filtered
zenodo_filtered <- zenodo_filtered %>%
  mutate(
    TaxonName = str_replace_all(TaxonName, " ", "_"),
    Region_all = case_when(
      Region %in% c("Portugal", "Azores", "Madeira") ~ "Portugal",
      Region %in% c("Spain", "Canary Islands", "Andorra") ~ "Spain",
      TRUE ~ NA_character_
    )
  )

# 2. Detect language from combined text fields in video dataset_geotag_1200km_new_locs_espanded
final_df_geotagged_dedup_1200km_new_locs_espanded <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
  mutate(
    text_combined = paste(
      ifelse(is.na(description), "", description),
      ifelse(is.na(title), "", title),
      ifelse(is.na(query), "", query)
    ),
    lang_detected = cld2::detect_language(text_combined, plain_text = TRUE),
    Region_all = case_when(
      lang_detected == "pt" ~ "Portugal",
      lang_detected %in% c("es", "ca", "gl", "eu", "ast") ~ "Spain",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-text_combined)  # drop helper column


# 3. Final merge on corrected TaxonName + Region_all
#combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
#  left_join(zenodo_filtered, by = c("TaxonName"))

library(dplyr)
library(tidyr)
library(flextable)
library(officer)

# Step 1: Replace NA in PresentStatus with "uncertain"
zenodo_filtered$PresentStatus[is.na(zenodo_filtered$PresentStatus)] <- "uncertain"

# Step 2: Create summary table of species by LifeForm and PresentStatus
summary_table_geotag_1200km_new_locs_espanded <- zenodo_filtered %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = n_species, values_fill = 0)

# Step 3: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% names(summary_table_geotag_1200km_new_locs_espanded)) summary_table_geotag_1200km_new_locs_espanded[[col]] <- 0
}

# Step 4: Add total species and % of total
summary_table_geotag_1200km_new_locs_espanded <- summary_table_geotag_1200km_new_locs_espanded %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 5: Add total row
total_row <- summary_table_geotag_1200km_new_locs_espanded %>%
  dplyr::summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = round(sum(total_species) / sum(total_species) * 100, 1)
  )

summary_table_geotag_1200km_new_locs_espanded_final <- bind_rows(summary_table_geotag_1200km_new_locs_espanded, total_row) %>%
  arrange(desc(total_species))

# Step 6: Export to CSV
write.csv(summary_table_geotag_1200km_new_locs_espanded_final, "summary_species_zenodo_filtered_geotag_1200km_new_locs_espanded.csv", row.names = FALSE)

# Step 7: Export to Word
ft <- flextable(summary_table_geotag_1200km_new_locs_espanded_final) %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

# Save as Word file
doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(value = ft)

print(doc, target = "summary_species_zenodo_filtered.docx")



combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- merge(final_df_geotagged_dedup_1200km_new_locs_espanded, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# 4. Preview results
print(head(combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded, 5))


# 1. Count distinct Region values per TaxonName
region_counts <- zenodo_filtered %>%
  group_by(TaxonName) %>%
  summarise(region_count = n_distinct(Region), .groups = "drop")

# 2. Join counts back into the main data
zenodo_with_region_counts <- zenodo_filtered %>%
  left_join(region_counts, by = "TaxonName")

# 3. Split into repeated-region and single-region subsets
zenodo_repeated_regions <- zenodo_with_region_counts %>%
  filter(region_count > 1)

zenodo_single_region <- zenodo_with_region_counts %>%
  filter(region_count == 1)

# 4. Drop the helper column if desired
zenodo_repeated_regions <- zenodo_repeated_regions %>% select(-region_count)
zenodo_single_region <- zenodo_single_region %>% select(-region_count)

# 5. Preview
cat("?? TaxonNames in multiple regions:\n")
print(unique(zenodo_repeated_regions$TaxonName))

cat("\n? TaxonNames in a single region:\n")
print(unique(zenodo_single_region$TaxonName))



library(dplyr)
library(tidyr)
library(gt)
library(flextable)
library(officer)

# Step 0: Clean list of searched species (you already created this earlier)
# species_names_clean <- gsub("_", " ", names(all_lists_ccommon_NEW_ES_PT_geotag_1200km_new_locs_espanded))

# Step 1: Add a temporary clean name column to zenodo_filtered for matching
zenodo_filtered <- zenodo_filtered %>%
  mutate(CleanName = gsub("_", " ", TaxonName))

# Step 2: Filter to only searched species using cleaned names
searched_zenodo <- zenodo_filtered %>%
  filter(CleanName %in% species_names_clean)

# Step 3: Combine found species (videos) with full metadata
combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- merge(final_df_geotagged_dedup_1200km_new_locs_espanded, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# Step 4: Remove "Mammals" group (1 case only in found)
combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded %>% filter(LifeForm != "Mammals")
searched_zenodo <- searched_zenodo %>% filter(LifeForm != "Mammals")
zenodo_filtered <- zenodo_filtered %>% filter(LifeForm != "Mammals")

# ? Step 5: Compute total species per LifeForm from the full Zenodo dataset_geotag_1200km_new_locs_espanded
total_species_summary <- zenodo_filtered %>%
  group_by(LifeForm) %>%
  summarise(total_species = n_distinct(TaxonName), .groups = "drop")

# Step 6: Compute searched species per LifeForm (subset of total)
searched_summary <- searched_zenodo %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(searched = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = searched, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_searched") %>%
  mutate(searched_species = rowSums(across(ends_with("_searched"))),
         pct_searched = round((searched_species / sum(searched_species)) * 100, 1))

# Step 7: Compute found species per LifeForm from combined dataset_geotag_1200km_new_locs_espanded
found_summary <- combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(found = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = found, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_found") %>%
  mutate(species_found = rowSums(across(ends_with("_found"))),
         pct_found = round((species_found / sum(species_found)) * 100, 1))

# Step 8: Join summaries
final_table <- searched_summary %>%
  full_join(found_summary, by = "LifeForm") %>%
  full_join(total_species_summary, by = "LifeForm") %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(
    Alien = paste0(alien_found, "/", alien_searched),
    Established = paste0(established_found, "/", established_searched),
    Uncertain = paste0(uncertain_found, "/", uncertain_searched),
    Casual = paste0(casual_found, "/", casual_searched),
    `% Found / Searched` = paste0(pct_found, "/", pct_searched),
    `% Found of Searched` = paste0(round((species_found / searched_species) * 100, 1), "%")
  ) %>%
  dplyr::select(
    `Taxonomic Group` = LifeForm,
    `Total Species` = total_species,
    `Searched Species` = searched_species,
    `Species Found` = species_found,
    `% Found of Searched`,
    `% Found / Searched`,
    Alien, Established, Uncertain, Casual
  )

# Step 9: Add total row
total_row <- final_table %>%
  summarise(
    `Taxonomic Group` = "Total",
    `Total Species` = sum(`Total Species`),
    `Searched Species` = sum(`Searched Species`),
    `Species Found` = sum(`Species Found`),
    `% Found of Searched` = paste0(round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "%"),
    `% Found / Searched` = paste0(
      round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "/100"
    ),
    Alien = paste0(sum(as.integer(sub("/.*", "", Alien))), "/", sum(as.integer(sub(".*/", "", Alien)))),
    Established = paste0(sum(as.integer(sub("/.*", "", Established))), "/", sum(as.integer(sub(".*/", "", Established)))),
    Uncertain = paste0(sum(as.integer(sub("/.*", "", Uncertain))), "/", sum(as.integer(sub(".*/", "", Uncertain)))),
    Casual = paste0(sum(as.integer(sub("/.*", "", Casual))), "/", sum(as.integer(sub(".*/", "", Casual))))
  )

# Step 10: Bind total row to final table
final_table <- bind_rows(final_table, total_row)

# Step 11: Export to Word
ft <- flextable(final_table) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ `Taxonomic Group` == "Total", part = "body")

doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group (Found vs Searched)", style = "heading 1") %>%
  body_add_flextable(ft)

print(doc, target = "summary_species_combined_found_vs_searched.docx")

# Step 12: Export to CSV
write.csv(final_table, "summary_species_combined_found_vs_searched_geotag_1200km_new_locs_espanded.csv", row.names = FALSE)



# 1. Find which TaxonName values are common
common_taxa <- intersect(
  unique(zenodo_single_region$TaxonName),
  unique(final_df_geotagged_dedup_1200km_new_locs_espanded$TaxonName)
)

# 2. Subset the video dataset_geotag_1200km_new_locs_espanded for these common TaxonNames
#videos_single_region <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
#  filter(TaxonName %in% common_taxa)

# 3. Merge matched video data with zenodo_single_region
#combined_single_region <- videos_single_region %>%
#    left_join(zenodo_single_region, by = "TaxonName")

# 4. Optional: Remove unmatched rows after merge (those where LifeForm or Region is still NA)
#combined_single_region_clean <- combined_single_region %>%
#  filter(!is.na(LifeForm))

# 5. Now get the remaining (unmatched) videos for later merge with repeated-region species
#videos_remaining <- final_df_geotagged_dedup_1200km_new_locs_espanded %>%
#  filter(!(TaxonName %in% common_taxa))

# 6. Preview results
#cat("? Combined single-region species dataset_geotag_1200km_new_locs_espanded:\n")
#print(head(combined_single_region, 3))

#cat("\n?? Remaining videos to combine with repeated-region species:\n")
#print(head(videos_remaining, 3))


############################################################################ FILTERING OUT UNRELATED YT CHANNELS ############################################################################################

channels_to_remove <- c("Andrea Espadas", "Guías Pal Esp", "Daniel Mendes", "Quadros Brasi", "AVIRUKÁ", "LA VIEJOTECA DE FERCHO", "IlloJuan")

combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded %>%
  filter(!(channelTitle %in% channels_to_remove))

# Optional: Preview removed rows if needed
removed_rows <- combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded %>%
  filter(channelTitle %in% channels_to_remove)

cat("?? Rows removed:\n")
print(unique(removed_rows$channelTitle))

cat("\n? Final dataset_geotag_1200km_new_locs_espanded dimensions:\n")
print(dim(combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded))


# Ensure your dataset_geotag_1200km_new_locs_espanded is a data.table
setDT(combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded)

# Count number of rows (videos) per TaxonName
species_counts_combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded <- combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded[, .N, by = TaxonName][order(-N)]

# View top species by video count
print(head(species_counts_combined_data_common_NEW_ES_PT_geotag_1200km_new_locs_espanded,30))

      TaxonName     N
                         <char> <int>
 1:              Vespa_velutina    67
 2:         Psittacus_erithacus    24
 3:              Bemisia_tabaci    21
 4:       Rugulopteryx_okamurae    13
 5:        Phthorimaea_absoluta    10
 6:          Ceratitis_capitata     7
 7:          Lonchura_oryzivora     7
 8:           Perca_fluviatilis     7
 9:      Platycerium_bifurcatum     6
10:          Synoicus_chinensis     6
11:          Xylella_fastidiosa     6
12:       Cydalima_perspectalis     5
13:   Leptoglossus_occidentalis     5
14:          Agapornis_fischeri     4
15:      Cherax_quadricarinatus     4
16:    Haliaeetus_leucocephalus     4
17:      Macrochelys_temminckii     4
18:              Platalea_ajaja     4
19:               Rapana_venosa     4
20:               Aedes_aegypti     3
21:        Cygnus_melancoryphus     3
22:       Dryocosmus_kuriphilus     3
23: Paratrechina_jaegerskioeldi     3
24:           Testudo_marginata     3
25:            Vespa_orientalis     3
26:        Zebrasoma_flavescens     3
27:        Agapornis_nigrigenis     2
28:             Anser_cygnoides     2
29:            Aratinga_jandaya     2
30:                Corvus_albus     2
                      TaxonName     N
                      
                      

################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################### REGION CODE DATASETS - COMMON ONLY ######################################################################################################################################################################### REGION CODE DATASETS - COMMON ONLY ######################################################################################################################################################################### REGION CODE DATASETS - COMMON ONLY ###########################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################


# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(cld2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)
library(officer)
library(readr)


final_region <- rbind(final_region_1,final_region_2,final_region_3,final_region_4,
                  final_region_5,final_region_6,final_region_7,final_region_8,
                  final_region_9,final_region_10,final_region_11,final_region_12,
                  final_region_13,final_region_14,final_region_15,final_region_16,
                  final_region_17,final_region_18,final_region_19,final_region_20,
                  final_region_21,final_region_22)

library(dplyr)

# Remove duplicates by video_id, title, and video_url
final_region_dedup <- final_region %>%
  distinct(video_id, title, video_url, .keep_all = TRUE)

# Check before/after
cat("Original rows:", nrow(final_region), "\n")
cat("Rows after removing duplicates:", nrow(final_region_dedup), "\n")

# Save if needed
write.csv(final_region_dedup, "yt_species_videos_ES_PT_regioncode_dedup.csv", row.names = FALSE)


################################################################################## REMOVE SCIENTIFIC NAMES FROM THE QUERIES AND KEEP COMMON NAMES ONLY ######################################################

# Packages
library(dplyr)
library(stringr)
library(purrr)

# ---- 1) Your scientific names vector (as provided) ----
all_lists_scientific_NEW_ES_PT_regioncode_common_only <- c(
  "Aedes japonicus",
  "Apalone ferox",
  "Amazona amazonica",
  "Eupsittula pertinax", "Aratinga pertinax",
  "Aphis illinoisensis", "Aphis Aphis illinoisensis",
  "Spatula hottentota",
  "Barbronia weberi",
  "Blastopsylla occidentalis",
  "Chenonetta jubata",
  "Columbina talpacoti",
  "Corvus albus",
  "Crangonyx pseudogracilis",
  "Cygnus melancoryphus",
  "Dryocosmus kuriphilus",
  "Gobio occitaniae",
  "Equisetum palustre",
  "Graptemys pseudogeographica",
  "Testudo_geographica",
  "Emys geographica",
  "Malaclemys georgraphica",
  "Grus canadensis", "Antigone canadensis", "Ardea canadensis",
  "Haemorhous mexicanus", "Carpodacus mexicanus",
  "Haliaeetus leucocephalus",
  "Ictalurus punctatus", "Silurus punctatus",
  "Leuciscus_aspius",
  "Lorius chlorocercus",
  "Macrochelys temminckii",
  "Maeotias marginata",
  "Marisa cornuarietis",
  "Microlepia platyphylla",
  "Mimus gilvus",
  "Musophaga violacea",
  "Netta peposaca",
  "Obolodiplosis robiniae",
  "Orientogalba viridis", "Austropeplea viridis", "Lymnaea viridis", "Radix viridis", "Austropeplea viridis",
  "Ommatotriton ophryticus",
  "Palaemon macrodactylus",
  "Pelodiscus sinensis",
  "Perca fluviatilis",
  "Phoeniculus purpureus",
  "Platycerium bifurcatum",
  "Pseudemys concinna",
  "Psittacus erithacus",
  "Psyllaephagus bliteus",
  "Rhodospiza obsoleta",
  "Sipha flava",
  "Stenopelmus rufinasus",
  "Styela plicata",
  "Testudo marginata",
  "Tockus deckeni",
  "Trachemys emolli",
  "Vespa velutina",
  "Zenaida meloda",
  "Lepisiota capensis",
  "Neotoxoptera formosana",
  "Phthorimaea absoluta", "Tuta absoluta",
  "Puto barberi",
  "Lonchura oryzivora",
  "Neophema pulchella",
  "Camponotus compressus",
  "Epidiplosis filifera",
  "Penthimiola bella",
  "Schizoporella errata",
  "Stenothoe georgiana",
  "Hercinothrips dimidiatus",
  "Hydrocharis laevigata",
  "Branta canadensis",
  "Bosmina coregoni", "Eubosmina coregoni",
  "Geranoaetus melanoleucus",
  "Geranoaetus polyosoma",
  "Hypoponera ergatandria",
  "Leptoglossus occidentalis",
  "Lobiopa insularis",
  "Crangonyx pseudogracilis",
  "Carassius gibelio",
  "Chrysonotomyia chamaeleon",
  "Epitrix similaris",
  "Glycaspis brimblecombei",
  "Pezothrips kellyanus",
  "Pomacea maculata", "Pomacea insularum",
  "Sophonia orientalis",
  "Agapornis fischeri",
  "Lasius neglectus",
  "Nylanderia jaegerskioeldi", "Paratrechina jaegerskioeldi", "Prenolepis fulva",
  "Pheidole indica", "Pheidole teneriffana", "Pheidole megacephala",
  "Strumigenys silvestrii",
  "Mnemiopsis leidyi",
  "Anoplolepis gracilipes",
  "Planorbella duryi", "Helisoma duryi",
  "Pseudosuccinea columella",
  "Pseudodiaptomus marinus",
  "Faxonius limosus", "Orconectes limosus",
  "Primolius auricollis",
  "Hemicypris barbadensis",
  "Hemicypris reticulata",
  "Delottococcus aberiae",
  "Aratinga jandaya", "Aratinga jandaia",
  "Belonochilus numenius",
  "Cereopsis novaehollandiae",
  "Brachymyrmex patagonicus", "Brachymyrmex heeri",
  "Blechnum occidentale",
  "Anas flavirostris",
  "Vespa orientalis",
  "Tapinoma melanocephalum", "Tapinoma pallipes",
  "Anser cygnoides",
  "Balistoides conspicillum",
  "Duttaphrynus melanostictus",
  "Varanus exanthematicus", "Lacerta exanthematicus", "Varanus ocellatus",
  "Vespa soror",
  "Vespa bicolor",
  "Lagocephalus sceleratus",
  "Zebrasoma flavescens", "Acanthurus flavescens",
  "Trachymela sloanei",
  "Xylotrechus chinensis",
  "Paracoccus burnerae",
  "Macrohomotoma gladiata",
  "Paracaprella pusilla",
  "Caprella scaura",
  "Dyspanopeus sayi",
  "Megabalanus tintinnabulum", "Balanus tintinnabulum",
  "Solidobalanus fallax",
  "Vanellus senegallus",
  "Chloephaga picta",
  "Acridotheres ginginianus",
  "Psilopsiagon aymara",
  "Elanoides forficatus",
  "Platalea ajaja",
  "Caloenas nicobarica",
  "Bycanistes brevis",
  "Caracara plancus",
  "Theora lubrica",
  "Atriplex semilunaris",
  "Pluchea carolinensis",
  "Axonopus fissifolius",
  "Eucheilota menoni",
  "Branchiomma bairdi",
  "Perinereis linea",
  "Perophora japonica",
  "Ensis leei",
  "Marginella glabella",
  "Sus scrofa var. domestica raza vietnamita",
  "Ferrissia californica",
  "Reticulitermes flavipes",
  "Acizzia jamatonica",
  "Acridotheres cristatellus",
  "Agapornis nigrigenis",
  "Amazona albifrons",
  "Amazona farinosa",
  "Amazona ochrocephala",
  "Amazonetta brasiliensis",
  "Aratinga leucophthalma", "Psittacara leucophthalmus",
  "Atheta mucronata",
  "Bemisia tabaci", "Aleyrodes tabaci",
  "Bursaphelenchus xylophilus",
  "Ceratitis capitata",
  "Diadema antillarum",
  "Drepanaphis acerifoliae",
  "Drosophila suzukii",
  "Eos squamata",
  "Euplectes macroura",
  "Paratrechina vividula",
  "Pionites melanocephalus",
  "Poicephalus crassus",
  "Primolius maracana",
  "Scyphophorus acupunctatus",
  "Thaumastocoris peregrinus",
  "Rugulopteryx okamurae",
  "Halimeda incrassata",
  "Aplidium accarense",
  "Epichrysocharis burwelli",
  "Ophelimus maskelli",
  "Tenellia adspersa",
  "Chrysonephos lewisii",
  "Crassula helmsii",
  "Molgula manhattensis",
  "Paracerceis sculpta",
  "Amathia verticillata",
  "Ficopomatus enigmaticus",
  "Caprella mutica",
  "Synoicus chinensis",
  "Phytophthora citricola",
  "Rapana venosa",
  "Tritia mutabilis",
  "Harmonia axyridis",
  "Psephotus haematonotus",
  "Pycnonotus jocosus",
  "Axonopus fissifolius",
  "Pyura herdmani",
  "Cydalima perspectalis",
  "Megachile sculpturalis",
  "Wasmannia auropunctata",
  "Mauremys reevesii",
  "Mauremys sinensis",
  "Ludwigia peploides",
  "Pseudemys peninsularis",
  "Spodoptera frugiperda",
  "Halyomorpha halys",
  "Aedes aegypti",
  "Euwallacea fornicatus",
  "Procambarus virginalis",
  "Cherax quadricarinatus",
  "Xylella fastidiosa",
  "Tobamovirus fructirugosum"
)

# ---- 2) Build a robust regex that matches scientific names in `query` ----
# Allow separators in the query to be space, underscore, or hyphen; match whole string (case-insensitive).

make_name_regex <- function(name) {
  # Trim & squeeze spaces
  name <- str_squish(name)
  # Split on spaces/underscores/hyphens
  parts <- str_split(name, "\\s+|[_-]+", n = Inf, simplify = FALSE)[[1]]
  # Escape any regex metacharacters in each token
  parts_esc <- str_replace_all(parts, "([\\W])", "\\\\\\1")
  # Join tokens with a separator class that allows space/_/-
  core <- paste(parts_esc, collapse = "(?:[ _-]+)")
  # Anchor to full string
  paste0("^", core, "$")
}

# Unique names, drop empties
sci_unique <- unique(all_lists_scientific_NEW_ES_PT_regioncode_common_only)
sci_unique <- sci_unique[nchar(str_squish(sci_unique)) > 0]

# Vector of anchored regexes
sci_regexes <- map_chr(sci_unique, make_name_regex)
# Single combined regex (OR)
sci_big_regex <- paste(sci_regexes, collapse = "|")

# ---- 3) Classify & filter the dataset ----
# Prepare a normalized 'query_norm' (trim multiple spaces)
final_region_dedup <- final_region_dedup %>%
  mutate(query_norm = str_squish(query))

# Flag rows where query is a scientific name (allow separators; ignore case)
is_scientific <- str_detect(final_region_dedup$query_norm, regex(sci_big_regex, ignore_case = TRUE))

# Keep only common-name queries
final_region_regioncode_common_only_dedup <- final_region_dedup %>% filter(!is_scientific) %>% select(-query_norm)

# (Optional) Also keep the scientific-name subset for reference/audit
final_region_scientific_only <- final_region_dedup %>% filter(is_scientific) %>% select(-query_norm)

# ---- 4) Rename datasets accordingly (objects already named) & quick summary ----
message(sprintf(
  "Rows total: %s | scientific-name queries removed: %s | kept (common-name queries): %s",
  nrow(final_region_dedup), sum(is_scientific, na.rm = TRUE), nrow(final_region_regioncode_common_only_dedup)
))

write.csv(final_region_regioncode_common_only_dedup, "youtube_final_unique_videos_common_NEW_ES_PT_regioncode_common_only.csv", row.names = FALSE)


################################################################################################### LIST OF SPECIES WITH SCIENTIFIC AND COMMON NAMES ########################################################

final_region_regioncode_common_only_dedup <- read_csv("youtube_final_unique_videos_common_NEW_ES_PT_regioncode_common_only.csv")

# Your provided list
all_lists_common_NEW_ES_PT_regioncode_common_only <- list(
  "Aedes_japonicus" = c(
      "Aedes japonicus",
      "Mosquito del Japón",
      "Mosquito Japón",
      "Mosquito del Japon",
      "Mosquito Japon",
      "Mosquito asiático",
      "Mosquito asiatico",
      "Mosquito asiático de los arbustos",
      "Mosquito asiatico de los arbustos"
  ),

  "Apalone_ferox" = c(
      "Apalone ferox",
      "Tortuga de closca tova de Florida",
      "Tortuga closca tova de Florida",
      "Tortuga de caparazón blando de Florida",
      "Tortuga caparazón blando de Florida",
      "Tortuga de caparazon blando de Florida",
      "Tortuga caparazon blando de Florida",
      "Tartaruga americana de caco mole",
      "Tartaruga-americana-de-casco-mole",
      "Tartaruga-de-casco-mole-americana",
      "Tartaruga de caparazón brando da Florida",
      "Tartaruga caparazón brando da Florida"
  ),

  "Amazona_amazonica" = c(
      "Amazona amazonica",
      "Amazona d'ales carbassa",
      "Amazona carbassa",
      "Amazona de as laranxas",
      "Amazona de ás laranxas",
      "Amazona alinaranxa",
      "Amazona d'ales taronja",
      "Amazona taronja",
      "Papagai d'ales carbassa",
      "Lloro d'ales taronges",
      "Lloro taronges",
      "Amazona alinaranja",
      "Papagaio d'asa laranja",
      "Kuritzaká", "Kuritzaka"
  ),

  "Eupsittula_pertinax" = c(
      "Eupsittula pertinax",
      "Aratinga pertinax",
      "Aratinga pertinaz",
      "Aratinga de coroneta blava",
      "Aratinga coroneta blava",
      "Aratinga de cara castaña",
      "Aratinga cara castaña",
      "Aratinga caraparda",
      "Periquito bochecha parda",
      "Periquito de bochechas pardas",
      "Periquito de garganta castanha"
  ),

  "Aphis_illinoisensis" = c(
      "Aphis illinoisensis",
      "Aphis Aphis illinoisensis",
      "Pulgón de la vid",
      "Pulgon de la vid",
      "Pulgão-preto-da-videira",
      "Pulgão preto",
      "Pulgão preto videira"
  ),

  "Spatula_hottentota" = c(
      "Spatula hottentota",
      "Cerceta hotentote",
      "Cerceta de hottentot",
      "Cerceta hottentot",
      "Xarxet hotentot",
      "Cerceta joi",
      "Ànec hotentot",
      "Cerceta hotentote",
      "Ànec hotentot",
      "Cerceta hottentot",
      "Marrequinha bico azul",
      "Marrequinha-de-bico-azul",
      "Zertzeta hotentot"
  ),

  "Barbronia_weberi" = c(
      "Barbronia weberi",
      "Sanguijuela asiática de agua dulce",
      "Sanguijuela asiatica de agua dulce",
      "Sanguijuela asiática agua dulce",
      "Sanguijuela asiatica agua dulce"
  ),

  "Blastopsylla_occidentalis" = c(
      "Blastopsylla occidentalis",
      "Chicharrita del brote",
      "Piojo saltarín del eucalipto",
      "Piojo saltarín del ocalitu"
  ),

  "Chenonetta_jubata" = c(
      "Chenonetta jubata",
      "Pato de crin",
      "Pato de crina",
      "Ànec de crinera",
      "Ànec crinera",
      "Ganso de melena",
      "Ahate kalpardun"

  ),

  "Columbina_talpacoti" = c(
      "Columbina talpacoti",
      "Columbina colorada",
      "Rolinha púrpura",
      "Rolinha corada",
      "Tórtora terrestre rogenca",
      "Tortora terrestre rogenca",
      "Tierrerita"
  ),

  "Corvus_albus" = c(
      "Corvus albus",
      "Bele azpizuri",
      "Bele azpizuria",
      "Cuervo pio",
      "Corb pitblac",
      "Corb pitblanc",
      "Corvo de coleira",
      "Corb pit blanc",
      "Corvo pego",
      "Bele azpizuri",
      "Corb blanc i negre",
      "Corb de pit blanc",
      "Cuervu píu",
      "Corvo-de-barriga-branca",
      "Gralha-seminarista",
      "Cuervu piu",
      "Erroi azpizuri"
  ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis"
  ),

  "Cygnus_melancoryphus" = c(
      "Cygnus melancoryphus",
      "Cigne coll negre",
      "Cisne cuellinegro",
      "Cisne cuello negro",
      "Cigne de coll negre",
      "Cisne de pescuezu prietu",
      "Cisne de pescuezu-prietu",
      "Cisne de pescoço preto",
      "Cisne-de-pescoço-preto",
      "Cisne de pescozo negro",
      "Beltxarga lepabeltz",
      "Beltxarga lepabeltza"
  ),

  "Dryocosmus_kuriphilus" = c(
      "Dryocosmus kuriphilus",
      "Avispilla del castaño",
      "Avispilla asiática del castaño",
      "Avispilla asiatica del castaño",
      "Cinipídeo do castanheiro",
      "Avespa do castiñeiro"
  ),

  "Gobio_occitaniae" = c(
      "Gobio occitaniae",
      "Gobio occitano"
  ),

  "Equisetum_palustre" = c(
      "Equisetum palustre",
      "Cola de caballo de los pantanos",
      "Cola de caballo de pantano",
      "Cavalinha do pântano",
      "Cavalinha do pantano",
      "Equiset palustre"
  ),

  "Graptemys_pseudogeographica" = c(
      "Graptemys pseudogeographica",
      "Testudo_geographica",
      "Emys geographica",
      "Malaclemys georgraphica",
      "Tortuga mapa falsa",
      "Tortuga falsa mapa",
      "Tortuga mapa del Mississipi",
      "Falsa corcunda do Mississippi",
      "Tartaruga falsa-corcunda",
      "Tartaruga corcunda do Mississipi",
      "Tartaruga falsa corcunda do Mississipi"
  ),

  "Grus_canadensis" = c(
      "Grus canadensis",
      "Antigone canadensis",
      "Ardea canadensis",
      "Grulla canadiense",
      "Grua del Canadà",
      "Grua del Canada",
      "Grou-americano",
      "Grou do Canadá",
      "Kurrilo kanadar",
      "Kurrilo kanadarra",
      "Grúa canadiana",
      "Grua canadiana",
      "Grou canadiano",
      "Grus proavus"
  ),


  "Haemorhous_mexicanus" = c(
      "Haemorhous mexicanus",
      "Carpodacus mexicanus",
      "Pinzón mexicano",
      "Pinzon mexicano",
      "Camachuelo mejicano",
      "Camachuelo mexicano",
      "Carpodaco doméstico",
      "Carpodaco domestico",
      "Pintarroxo mexicano",
      "Picaflor mexicanu",
      "Pinsà casolà",
      "Pinsà casola",
      "Pinsa casola",
      "Pinsà mexicà",
      "Pintarroxo caseiro",
      "Pintarroxo do deserto",
      "Burugorri arrunt",
      "Burugorri arrunta"
  ),

  "Haliaeetus_leucocephalus" = c(
      "Haliaeetus leucocephalus",
      "Águila americana",
      "Aguila americana",
      "Pigargo americano",
      "Pigargo cabeza branca",
      "Pigargo cabeza blanca",
      "Pigargo de cabeza blanca",
      "Pigargo de cabeza branca",
      "Aguila de cap blanc",
      "Àguila cap blanc",
      "Àguila de cap blanc",
      "Pigarg americà",
      "Itsas arrano buruzuri",
      "Itsas arrano buruzuria",
      "Arrano buruzuri",
      "Arrano buruzuria",
      "Águia-americana",
      "Águia-de-cabeça-branca",
      "Itsas buruzuri",
      "Itsas buruzuria"
  ),

  "Ictalurus_punctatus" = c(
      "Ictalurus punctatus",
      "Silurus punctatus",
      "Peix gat americà",
      "Pez gato americano",
      "Bagre_americano",
      "Bagre de canal",
      "Bagre del canal",
      "Peixe gato americano",
      "Pez gato punteado",
      "Bagre canal"
  ),

  "Leuciscus_aspius" = c(
      "Leuciscus_aspius",
      "Aspio"
  ),

  "Lorius_chlorocercus" = c(
      "Lorius chlorocercus",
      "Lori acollarado",
      "Lori collar groc",
      "Lori de collar groc",
      "Lóris-de-colar-amarelo",
      "Lóris colar amarelo",
      "Loris de colar amarelo",
      "Loris colar amarelo",
      "Lóri-de-colar-amarelo"
  ),

  "Macrochelys_temminckii" = c(
      "Macrochelys temminckii",
      "Tortuga caimán",
      "Tortuga caiman",
      "Tortuga aligator",
      "Tortuga cocodrilo mordedora",
      "Tartaruga aligátor",
      "Tartaruga aligator",
      "Tartaruga mordedora de cocodrilo"
  ),

  "Maeotias_marginata" = c(
      "Maeotias marginata",
      "Hidromedusa de agua salobre",
      "Hidromedusa agua salobre",
      "Medusa del mar Negro"
  ),

  "Marisa_cornuarietis" = c(
      "Marisa cornuarietis",
      "Caracol cuerno de carnero gigante",
      "Caracol cuerno carnero gigante",
      "Caracol cuerno gigante de borrego",
      "Caracol cuerno gigante borrego",
      "Caracol cuerno de carnero",
      "Caracol cuerno carnero",
      "Caracol cuerno borrego",
      "Caracol colombiano",
      "Caragol banya de carner gegant",
      "Caragol colombià"
  ),

  "Microlepia_platyphylla" = c(
      "Microlepia platyphylla"
  ),

  "Mimus_gilvus" = c(
      "Mimus gilvus",
      "Sinsonte tropical",
      "Sinsont tropical",
      "Mim de sabana",
      "Mim de les sabanes",
      "Imitador tropical",
      "Pájaro imitador tropical",
      "Mirla blanca",
      "Sabiá-da-praia",
      "Sabia da praia",
      "Mimo-tropical",
      "Mimu tropical",
      "Tordo-imitador-da-praia",
      "Zentzuntle tropikal"
  ),

  "Musophaga_violacea" = c(
      "Musophaga violacea",
      "Turaco violáceo",
      "Turaco violaceo",
      "Turac violaci",
      "Turaco violeta",
      "Turacu violaceu",
      "Turako bioleta",
      "Pavão-azul"
  ),

  "Netta_peposaca" = c(
      "Netta peposaca",
      "Pato peposaca",
      "Xibec peposaca",
      "Peposaka ahate",
      "Peposaka ahatea",
      "Zarro patagónico",
      "Parrulo patagónico"
  ),

  "Obolodiplosis_robiniae" = c(
      "Obolodiplosis robiniae",
      "Mosquito de las agallas de la robinia"
  ),

  "Orientogalba viridis" = c(
      "Orientogalba viridis",
      "Austropeplea viridis",
      "Lymnaea viridis",
      "Radix viridis",
      "Austropeplea viridis",
      "Caracol anfibio de agua dulce"
  ),

  "Ommatotriton_ophryticus" = c(
      "Ommatotriton ophryticus",
      "Tritón crestado turco",
      "Tritón con bandas del norte",
      "Tritón bandas norte",
      "Tritão-de-banda-do-Norte",
      "Tritó caucàsic",
      "Triton ophryticus",
      "Triturus ophryticus"
  ),

  "Palaemon_macrodactylus" = c(
      "Palaemon macrodactylus",
      "Camarón emigrante", "Camarón-emigrante", "Camarón_emigrante"
  ),

  "Pelodiscus_sinensis" = c(
      "Pelodiscus sinensis",
      "Tortuga china de caparazón blando",
      "Tortuga china de caparazon blando",
      "Tortuga china caparazón blando",
      "Tortuga china caparazon blando",
      "Tortuga china de concha blanda",
      "Galápago de conchablanda chino",
      "Galapago de conchablanda chino",
      "Galápago conchablanda chino",
      "Galápago de concha blanda chino",
      "Galapago de concha blanda chino",
      "Tortuga de caparazón blando china",
      "Tortuga de caparazon blando china",
      "Tartaruga-de-carapaça-mole-chinesa",
      "Tartaruga carapaça mole chinesa",
      "Tortuga de cloca tova xinesa",
      "Tortuga de petxina tova xinesa",
      "Tortuga de cloaca tova xinesa",
      "Tartaruga chinesa de caparazón brando"
  ),

  "Perca_fluviatilis" = c(
      "Perca fluviatilis",
      "Perca río",
      "Perca rio",
      "Perca ríu",
      "Perca riu",
      "Perca de río",
      "Perca de rio",
      "Perca europea",
      "Perca euraiática",
      "Perca euraiatica",
      "Perca de ríu",
      "Perca de riu",
      "Perca común",
      "Perca comun",
      "Perka arrunta",
      "Perka arrunt",
      "Perca europeia"
  ),

  "Phoeniculus_purpureus" = c(
      "Phoeniculus purpureus",
      "Puput dels arbres verd",
      "Abubilla arbórea verde",
      "Abubilla arborea verde",
      "Abubilla verde",
      "Puput dels arbres verda",
      "Puput arbres verda",
      "Puput arbòria verda",
      "Puput arboria verda",
      "Zombeteiro purpúreo",
      "Zombeteiro purpureo",
      "Zombeteiro de bico vermelho"
  ),

  "Platycerium_bifurcatum" = c(
      "Platycerium bifurcatum",
      "Cuerno de alce",
      "Falguera banya",
      "Falguera banya d'ant",
      "Banya d'Ant",
      "Banya de cérvol",
      "Cacho de venado",
      "Cacho venado",
      "Cachovenado",
      "Helecho cuerno",
      "Helecho cuerno de alce",
      "Helecho de ciervo",
      "Helecho ciervo",
      "Helecho cuerno de ciervo",
      "Helecho cuerno de venado",
      "Helecho de alce",
      "Staghorn iratzea"
  ),

  "Pseudemys_concinna" = c(
      "Pseudemys concinna",
      "Tortuga jeroglífico",
      "Tortuga jeroglifico",
      "Tortuga jeroglífica",
      "Tartaruga hieroglífica",
      "Tartaruga hieroglifica",
      "Tortuga hieroglyphica"
  ),

  "Psittacus_erithacus" = c(
      "Psittacus erithacus",
      "Loro yaco",
      "Yaco de cola roja",
      "Yaco cola roja",
      "Loro gris de cola roja",
      "Loro gris cola roja",
      "Loro gris africano",
      "Loro gris africano de cola roja",
      "Lloro gris",
      "Lloro gris cuavermell",
      "Lloro gris cua-roig",
      "Lloro gris africà",
      "Lloro cuavermell",
      "Papagaio-cinzento",
      "Papagaio-do-congo",
      "Loro gris afrikarra",
      "Loru gris africanu"
  ),

  "Psyllaephagus_bliteus" = c(
      "Psyllaephagus bliteus"
  ),

  "Rhodospiza_obsoleta" = c(
      "Rhodospiza obsoleta",
      "Camachuelo desertícola",
      "Camachuelo deserticola",
      "Pinsà rosat del desert",
      "Pinsa rosat del desert",
      "Pinsà del desert",
      "Pinsa del desert",
      "Pimpín do deserto",
      "Pimpin do deserto",
      "Pintarroxo do deserto",
      "Verdilhão do deserto",
      "Verdilhao-do-deserto",
      "Basamortuko txonta"
  ),

  "Sipha_flava" = c(
      "Sipha flava",
      "Pulgón amarillo de la caña de azúcar",
      "Pulgón amarillo de la caña de azucar",
      "Pulgon amarillo de la caña de azucar",
      "Pulgón amarillo de caña de azúcar",
      "Pulgón amarillo de caña de azucar",
      "Pulgon amarillo de caña de azucar",
      "Pulgão-amarelo-da-cana-de-açúcar",
      "Pulgão-amarelo-da-cana-de-açucar",
      "Pulgón amarillo azúcar",
      "Pulgon amarillo azúcar",
      "Pulgon amarillo azucar",
      "Pugó groc de la canya de sucre"
  ),

  "Stenopelmus_rufinasus" = c(
      "Stenopelmus rufinasus"
  ),

  "Styela_plicata" = c(
      "Styela plicata",
      "Patata de mar",
      "Patata de Mer"
  ),

  "Testudo_marginata" = c(
      "Testudo marginata",
      "Tortuga marginada",
      "Tortuga almenada",
      "Dortoka ertz zabal",
      "Dortoka ertz zabala",
      "Tartaruga marginata"
  ),

  "Tockus_deckeni" = c(
      "Tockus deckeni",
      "Toco keniata",
      "Toco de Von der Decken",
      "Toco Von der decken",
      "Calau de von der decken",
      "Calau Decken",
      "Calau de Decken"
  ),

  "Trachemys_emolli" = c(
      "Trachemys emolli",
      "Tortuga nicaragüene",
      "Tortuga nicaraguense",
      "Tortuga escurridiza de Nicaragua",
      "Tartaruga de Nicaragua",
      "Tartaruga da Nicarágua"
  ),

  "Vespa_velutina" = c(
      "Vespa velutina",
      "Avispa asiática",
      "Avispa asiatica",
      "Avispa negra asiática",
      "Avispa negra asiatica",
      "Avispón negro asiático",
      "Avispón negro asiatico",
      "Avispon negro asiático",
      "Avispon negro asiatico",
      "Avispa asiática gigante",
      "Avispa asiatica gigante",
      "Vespa carnissera asiàtica",
      "Vespa carnissera asiatica",
      "Avespa asiática",
      "Avespa asiatica",
      "Vespa asiàtica",
      "Vespa asiatica",
      "Vespão asiático",
      "Vespão asiatico",
      "Vespa carnicera asiàtica",
      "Vespa carnicera asiatica",
      "Avispa asesina",
      "Liztor asiarrra",
      "Liztor asiar",
      "Asiako liztor beltza"
  ),

  "Zenaida_meloda" = c(
      "Zenaida meloda",
      "Zenaida peruana",
      "Tórtora de costa",
      "Paloma cuculina",
      "Rola-do-pacífico"
  ),

  "Lepisiota_capensis" = c(
      "Lepisiota capensis",
      "Hormiga azucarera africana"
  ),

  "Neotoxoptera_formosana" = c(
      "Neotoxoptera formosana",
      "Pulgón de la cebolla",
      "Pulgon de la cebolla",
      "Pulgão da cebola"
  ),

  "Phthorimaea_absoluta" = c(
      "Phthorimaea absoluta",
      "Tuta absoluta",
      "Cogollero del tomate",
      "Gusano minador del tomate",
      "Minador de hojas y tallos de la papa",
      "Minador de la hoja del tomate",
      "Polilla del tomate",
      "Palomilla del tomate",
      "Arna de la tomaca",
      "Arna del tomàquet",
      "Arna del tomaquet",
      "Arna tomàquet",
      "Arna tomaquet",
      "Couza do tomate",
      "Cuc minador del tomaca",
      "Cuc del tomàquet",
      "Cuc del tomaquet",
      "Avelaíña do tomate",
      "Tomatearen sitsa",
      "Traça-do-tomateiro",
      "Traça tomateiro"
  ),

  "Puto_barberi" = c(
      "Puto barberi",
      "Cochinilla blanca de la raíz",
      "Cochinilla blanca de la raiz",
      "Cochinilla del café",
      "Cochinilla del cafe",
      "Cochinilla gigante de Barber",
      "Cochinilla gigante Barber"
  ),

  "Lonchura_oryzivora" = c(
      "Lonchura oryzivora",
      "Capuchino arrocero de Java",
      "Gorrión de Java",
      "Gorrion de Java",
      "Maniquí galtablanc",
      "Maniqui galtablanc",
      "Maniquí de Java",
      "Maniqui de Java",
      "Pardal de java",
      "Pardal de Java",
      "Pardal de Xava",
      "Padda de Java"
  ),

  "Neophema_pulchella" = c(
      "Neophema pulchella",
      "Periquito turquesa"
  ),

  "Camponotus_compressus" = c(
      "Camponotus compressus"
  ),

  "Epidiplosis_filifera" = c(
      "Epidiplosis filifera"
  ),

  "Penthimiola_bella" = c(
      "Penthimiola bella"
  ),

  "Schizoporella_errata" = c(
      "Schizoporella errata"
  ),

  "Stenothoe_georgiana" = c(
      "Stenothoe georgiana"
  ),


  "Hercinothrips_dimidiatus" = c(
      "Hercinothrips dimidiatus"
  ),

  "Hydrocharis_laevigata" = c(
      "Hydrocharis laevigata"
  ),

  "Branta_canadensis" = c(
      "Branta canadensis",
      "Barnacla canadiense",
      "Barnacla canadiense grande",
      "Oca del Canadà",
      "Ganso-do-Canadá",
      "Ganso-do-Canada",
      "Gansu canadianu",
      "Gansu canadiense",
      "Gansu de Canada",
      "Branta kanadar",
      "Branta kanadar handi",
      "Branta kanadarra",
      "Kanadako branta"
  ),

  "Bosmina_coregoni" = c(
      "Bosmina coregoni",
      "Eubosmina coregoni"
  ),

  "Geranoaetus_melanoleucus" = c(
      "Geranoaetus melanoleucus",
      "Águila mora",
      "Águila escudada",
      "Àguila pitnegra",
      "Aguila mora",
      "Aguila escudada",
      "Aguila pitnegra",
      "Águila escudada",
      "Àguila escudada",
      "Águia serrana",
      "Bútio-de-peito-preto",
      "BUtio-de-peito-preto",
      "Zapelatz paparbeltz",
      "Zapelatz paparbeltza"
   ),

  "Geranoaetus_polyosoma" = c(
      "Geranoaetus polyosoma",
      "Busardo dorsirrojo",
      "Aligot tricolor",
      "Bútio-de-dorso-vermelho",
      "Butio-de-dorso-vermelho",
      "Bútio variável",
      "Zapelatz aldakor",
      "Zapelatz aldakorra"
   ),

   "Hypoponera_ergatandria" = c(
      "Hypoponera ergatandria"
   ),

   "Leptoglossus_occidentalis" = c(
      "Leptoglossus occidentalis",
      "Chinche americana del pino",
      "Chinche americana de pino",
      "Chinche americano del pino",
      "Chinche americano de pino",
      "Chinche americana de las piñas",
      "Chinche de las piñas",
      "Xinxa americana del pi",
      "Xinxa americana dels pins",
      "Xinxa americana del pins",
      "Inseto pinheiro americano"
   ),

    "Lobiopa_insularis" = c(
      "Lobiopa insularis"
   ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis",
      "Pulga de agua del norte",
      "Pulga-de-água-do-norte",
      "Pulga-de-Agua-do-norte",
      "Pulga água do norte"
  ),

  "Carassius_gibelio" = c(
      "Carassius gibelio",
      "Carpa prusiana",
      "Carpa prussiana",
      "Carpa prussiana prateada",
      "Carpa-prusiana-prateada",
      "Pimpão cinzento"
  ),

  "Chrysonotomyia_chamaeleon" = c(
      "Chrysonotomyia chamaeleon"
  ),

   "Epitrix_similaris" = c(
      "Epitrix similaris",
      "Pulguilla de la patata",
      "Pulguilla de patata",
      "Pulguilla de la papa",
      "Pulga saltona",
      "Pulguilla saltona"
   ),

   "Glycaspis_brimblecombei" = c(
      "Glycaspis brimblecombei",
      "Psílido del eucalipto rojo",
      "Psílido rojo del eucalipto",
      "PsIlido del eucalipto rojo",
      "PsIlido rojo del eucalipto",
      "Conchuela australiana del eucalipto",
      "Conchuela del eucalipto"
   ),

   "Pezothrips_kellyanus" = c(
      "Pezothrips kellyanus",
      "Trips de los cítricos de Kelly",
      "Trips de los cítricos",
      "Trips de los citricos de Kelly",
      "Trips de los citricos",
      "Trips dels cítrics"
   ),

   "Pomacea_maculata" = c(
      "Pomacea maculata",
      "Pomacea insularum",
      "Caracol manzana gigante",
      "Caracol mazá xigante",
      "Cargol poma tacat",
      "Cargol poma gegant"
   ),

   "Sophonia_orientalis" = c(
      "Sophonia orientalis",
      "Chicharrita asiática de dos manchas",
      "Chicharrita asiatica de dos manchas"
   ),

   "Agapornis_fischeri" = c(
      "Agapornis fischeri",
      "Inseparable de Fischer",
      "Inseparábel de Fischer",
      "Inseparabel de Fischer",
      "Inseparável de fischer",
      "Inseparavel de fischer",
      "Agapornis de Fischer",
      "Inseparável-alaranjado"
   ),

  "Lasius_neglectus" = c(
      "Lasius neglectus",
      "Hormiga invasora de jardines",
      "Hormiga invasora de los jardines",
      "Hormiga de jardín invasora",
      "Formiga invasora de jardins",
      "Formiga invasora dels jardins",
      "Formiga de jardí invasora",
      "Formiga de xardín invasora",
      "Formiga invasora de jardim"
  ),

  "Paratrechina_jaegerskioeldi" = c(
      "Nylanderia jaegerskioeldi",
      "Paratrechina jaegerskioeldi",
      "Prenolepis fulva",
      "Hormiga loca",
      "Formiga boja"
  ),

   "Pheidole_indica" = c(
      "Pheidole indica",
      "Pheidole teneriffana",
      "Hormiga cabezona india"
   ),

   "Pheidole_megacephala" = c(
      "Pheidole megacephala",
      "Hormiga leona",
      "Hormiga africana cabezona",
      "Hormiga cabezona africana",
      "Formiga africana cabezona",
      "Formiga africana de cabeça grande",
      "Formiga africana cabezuda",
      "Formiga cabezuda africana",
      "Hormiga cabezona africana"
   ),

   "Strumigenys_silvestrii" = c(
      "Strumigenys silvestrii"
   ),

   "Mnemiopsis_leidyi" = c(
      "Mnemiopsis leidyi",
      "Medusa bombilla",
      "Ctenóforo americano",
      "Medusa bombeta",
      "Anou de mar"
   ),

    "Anoplolepis_gracilipes" = c(
      "Anoplolepis gracilipes",
      "Hormiga zancona",
      "Hormiga loca amarilla",
      "Hormiga loca amarilla africana",
      "Hormiga loca amarilla de África",
      "Hormiga loca amarilla de Africa",
      "Formiga boja groga",
      "Formiga louca amarela",
      "Formiga tola amarela"
    ),

    "Planorbella_duryi" = c(
      "Planorbella duryi",
      "Helisoma duryi",
      "Planorbis de Florida"
    ),

    "Pseudosuccinea_columella" =c(
      "Pseudosuccinea columella",
      "Caracol americano de los trematodos",
      "Caracol americano de trematodos",
      "Caracol de la duela del hígado"
    ),

    "Pseudodiaptomus_marinus" = c(
      "Pseudodiaptomus marinus"
    ),

    "Faxonius_limosus" = c(
      "Faxonius limosus",
      "Orconectes limosus",
      "Cangrejo de los canales",
      "Cangrejo de río de los canales",
      "Cangrejo río de los canales",
      "Cangrejo de rio de los canales",
      "Cangrejo rio de los canales",
      "Cangrejo de canales",
      "Cranc dels canals",
      "Cranc del riu dels canals"
     ),

     "Primolius_auricollis" = c(
      "Primolius auricollis",
      "Guacamayo acollarado",
      "Guacamaya cuello dorado",
      "Guacamaya de cuello dorado",
      "Maracanã-de-colar",
      "Guacamai colldaurat",
      "Arara-de-colar-dourado"
     ),

     "Hemicypris_barbadensis" = c(
      "Hemicypris barbadensis"
     ),

     "Hemicypris_reticulata" = c(
      "Hemicypris reticulata"
     ),

     "Delottococcus_aberiae" = c(
      "Delottococcus aberiae",
      "Cottonet de les Valls",
      "Cottonet de Valls",
      "Cotonet de les Valls",
      "Cotonet de Valls",
      "Cotonet de Sudáfrica",
      "Cotonet de Sudafrica"
     ),

     "Aratinga_jandaya" = c(
      "Aratinga jandaya",
      "Aratinga jandaia",
      "Cotorra jandaya",
      "Jandaia-verdadeira",
      "Periquitão-nordestino"
      ),

     "Belonochilus_numenius" = c(
      "Belonochilus numenius",
      "Chinche del sicomoro",
      "Chinche del sicómoro",
      "Chinche de la semilla del sicómoro",
      "Chinche de la semilla del sicomoro"
      ),

     "Cereopsis_novaehollandiae" = c(
      "Cereopsis novaehollandiae",
      "Ganso cenizo",
      "Ganso ceniciento",
      "Oca cendrosa",
      "Ganso cinzento australiano",
      "Ganso cinzento",
      "Antzara hauskara"
      ),

     "Brachymyrmex_patagonicus" = c(
      "Brachymyrmex patagonicus",
      "Hormiga rover oscura",
      "Hormiga rover negra"
      ),

     "Brachymyrmex_heeri" = c(
      "Brachymyrmex heeri"
      ),

     "Cardiocondyla_obscurior" = c(
      "Cardiocondyla obscurior"
      ),

     "Blechnum_occidentale" = c(
      "Blechnum occidentale"
      ),

     "Anas_flavirostris" = c(
      "Anas flavirostris",
      "Marreca-pardinha",
      "Marrequinha-de-bico-amarelo",
      "Cerceta barcina",
      "Xarxet becgroc",
      "Zertzeta mokohori"
      ),

     "Vespa_orientalis" = c(
      "Vespa orientalis",
      "Vespa oriental",
      "Avispón oriental",
      "Avispon oriental",
      "Avispa oriental"
      ),

     "Tapinoma_melanocephalum" = c(
      "Tapinoma melanocephalum",
      "Hormiga fantasma",
      "Hormiga boticaria",
      "Formiga fantasma"
      ),

     "Tapinoma_pallipes" = c(
      "Tapinoma pallipes"
      ),

     "Anser_cygnoides" = c(
      "Anser cygnoides",
      "Ánsar cisnal",
      "Ansar cisnal",
      "Oca cigne",
      "ánsar cisne",
      "Ansar cisne",
      "Ganso cisnal",
      "Ganso cisne",
      "Ganso africano",
      "Ganso chinês",
      "Beltxarga antzara"
      ),

    "Balistoides_conspicillum" = c(
     "Balistoides conspicillum",
     "Pez ballesta payaso",
     "Pez ballesta payasu",
     "Peixe ballesta pallaso",
     "Peix ballesta pallasso",
     "Peixe-porco-palhaço",
     "Cangulo palhaço"
     ),

    "Duttaphrynus_melanostictus" = c(
     "Duttaphrynus melanostictus",
     "Sapo común asiático",
     "Sapo comun asiatico",
     "Sapo comun asiático",
     "Sapo común asiatico",
     "Sapo comum asiático",
     "Sapo comum asiatico",
     "Sapu común asiáticu",
     "Gripau comú asiàtic",
     "Gripau comú asiatic",
     "Gripau comu asiàtic"
     ),

    "Varanus_exanthematicus" = c(
     "Varanus exanthematicus",
     "Lacerta exanthematicus",
     "Varanus ocellatus",
     "Varano de sabana",
     "Varano de la sabana",
     "Varano de Bosc",
     "Varano de bosc",
     "Varà de sabana",
     "Varà de Bosc",
     "Varano terrestre africano",
     "Varano das savanas",
     "Monitor de savana",
     "Monitor de la sabana",
     "Monitor de sabana"
     ),

    "Vespa_soror" = c(
     "Vespa soror",
     "Avispón sóror",
     "Avispon sóror",
     "Avispón soror",
     "Avispon soror",
     "Avispón gigante del sur",
     "Avispon gigante del sur",
     "Avispa gigante del sur",
     "Vespa gegant del sud",
     "Avispón xigante do sur",
     "Avispon xigante do sur",
     "Vespa-gigante-do-sul"
     ),

    "Vespa_bicolor" = c(
     "Vespa bicolor",
     "Avispa bicolor",
     "Avispón bicolor",
     "Avispon bicolor",
     "Avispa escudo negro",
     "Avispón de escudo negro",
     "Avispón escudo negro",
     "Avispon de escudo negro",
     "Avispon escudo negro"
    ),

    "Lagocephalus_sceleratus" = c(
     "Lagocephalus sceleratus",
     "Piraña del Mediterráneo",
     "Pez sapo de mejillas plateadas",
     "Pez globo plateado",
     "Peixe-balão sapo-de-bochecha-prateada",
     "Peixe-balão-sapo-de-bochecha-prateada",
     "Peixe-balão prateado",
     "Peixe-balão-prateado",
     "Peixe-sapo de bochechas prateadas"
     ),

    "Zebrasoma_flavescens" = c(
     "Zebrasoma flavescens",
     "Acanthurus flavescens",
     "Pez cirujano amarillo",
     "Navajón velero amarillo",
     "Peix cirurgià groc",
     "Cirurgião-amarelo",
     "Peixe-cirurgião-amarelo"
     ),

   "Trachymela_sloanei" = c(
    "Trachymela sloanei",
    "Escarabajo tortuga australiano",
    "Besouro-tartaruga australiano",
    "Besouro-tartaruga-de-eucalipto",
    "Besouro-tartaruga de eucalipto"
     ),

   "Xylotrechus_chinensis" = c(
    "Xylotrechus chinensis",
    "Escarabajo avispa taladro de las moreras",
    "Escarabajo-avispa taladro de las moreras",
    "Escarabajo perforador de las moreras",
    "Escarabajo-avispa barrenador de las moreras",
    "Escarabat vespa barrinador de les moreres",
    "Escarabat vespa barrinador de moreres",
    "Escarabat-vespa barrinador de moreres",
    "Escarabat barrinador de les moreres",
    "Escarabat-barrinador de les moreres",
    "Escarabat vespa escombrador de les moreres",
    "Escarabat-vespa escombrador de les moreres"
     ),

   "Paracoccus_burnerae" = c(
    "Paracoccus burnerae",
    "Cochinilla de la adelfa"
     ),

   "Macrohomotoma_gladiata" = c(
    "Macrohomotoma gladiata",
    "Psila del ficus",
    "Psil·la del ficus",
    "Psilla del ficus"
     ),

   "Paracaprella_pusilla" = c(
    "Paracaprella pusilla"
     ),

   "Caprella_scaura" = c(
    "Caprella scaura",
    "Gamba esqueleto",
    "Gamba fantasma"
     ),

   "Dyspanopeus_sayi" = c(
    "Dyspanopeus sayi",
    "Cangrejo marino americano",
    "Cranc marí americà",
    "Pequeño cangrejo de barro"
     ),

   "Megabalanus_tintinnabulum" = c(
    "Megabalanus tintinnabulum",
    "Balanus tintinnabulum",
    "Percebe bellota"
     ),

   "Solidobalanus_fallax" = c(
    "Solidobalanus fallax"
     ),

   "Vanellus senegallus" = c(
    "Vanellus senegallus",
    "Avefría senegalesa",
    "Avefría del Senegal",
    "Fredeluga del Senegal",
    "Fredeluga senegalesa",
    "Avefría do Senegal",
    "Abibe carunculado",
    "Abibe carúncula",
    "Abibe caruncula"
     ),

   "Chloephaga_picta" = c(
    "Chloephaga picta",
    "Cauquén común",
    "Cauquen común",
    "Cauquén comun",
    "Cauquen comun",
    "Cauquén magallánico",
    "Cauquén magallanico",
    "Cauquen magallánico",
    "Cauquen magallanico",
    "Oca de Magallanes",
    "Ganso patagónico",
    "Ganso-magalhânico",
    "Ganso magallánico",
    "Ganso de Magallanes",
    "Avutarda magallánica",
    "Avutarda de Magallanes",
    "Magallaesko antzara",
    "Magallanes antzarra"
     ),

   "Acridotheres_ginginianus" = c(
    "Acridotheres ginginianus",
    "Miná ribereño",
    "Minà de ribera",
    "Minà fosc",
    "Mainá ribeiriño",
    "Mainá oscura",
    "Mainà riberenc"
     ),

   "Psilopsiagon_aymara" = c(
    "Psilopsiagon aymara",
    "Catita aimará",
    "Cotorreta encaputxada",
    "Periquito-da-serra",
    "Periquito-aimara"
     ),

   "Elanoides_forficatus" = c(
    "Elanoides forficatus",
    "Elanio tijereta",
    "Esparver cuaforcat",
    "Milà de cua forcada",
    "Elani cuaforcat",
    "Elano mir-buztanduna",
    "Elano miru-buztan",
    "Elano miru buztana",
    "Gabián tesoira",
    "Gavião-tesoura",
    "Falcão-tesoura"
     ),

   "Platalea_ajaja" = c(
    "Platalea ajaja",
    "Espátula rosada",
    "Becplaner rosat",
    "Cullereiro americano",
    "Cullereiro rosa",
    "Colhereiro-americano",
    "Colhereiro-rosado",
    "Mokozabal arrosa"
     ),

   "Caloenas_nicobarica" = c(
    "Caloenas nicobarica",
    "Paloma de Nicobar",
    "Paloma Nicobar",
    "Colom de les illes Nicobar",
    "Colom de les Nicobar",
    "Colom de Nicobar",
    "Pombo-de-nicobar",
    "Pombo Nicobar"
     ),

   "Bycanistes_brevis" = c(
    "Bycanistes brevis",
    "Cálao cariplateado",
    "Calau de galtes argentades",
    "Calau galtaargentat",
    "Calau galtes argentades",
    "Calau-de-faces-prateadas",
    "Calau-de-face-prateada",
    "Calau-faces-prateadas",
    "Calau-face-prateada"
     ),

   "Caracara_plancus" = c(
    "Caracara plancus",
    "Caracara carancho",
    "Carancho meridional",
    "Caracarà crestat meridional",
    "Caracarà crestat",
    "Caracara-de-crista",
    "Carcará-de-poupa",
    "Karakara mottodun"
     ),

   "Theora_lubrica" = c(
    "Theora lubrica"
     ),

   "Atriplex_semilunaris" = c(
    "Atriplex semilunaris"
     ),

   "Pluchea_carolinensis" = c(
    "Pluchea carolinensis",
    "Ciguapate"
     ),

   "Axonopus_fissifolius" = c(
    "Axonopus fissifolius",
    "Hierba de alfombra común",
    "Hierba de alfombra comun",
    "Grama brasilera"
     ),

   "Eucheilota_menoni" = c(
    "Eucheilota menoni"
     ),

   "Branchiomma_bairdi" = c(
    "Branchiomma bairdi"
     ),

   "Perinereis_linea" = c(
    "Perinereis linea"
     ),

   "Perophora_japonica" = c(
    "Perophora japonica",
    "Tunicado del Indopacífico",
    "Tunicado Indopacífico",
    "Tunicado Indo-Pacífico",
    "Tunicado del Indopacifico",
    "Tunicado Indopacifico",
    "Tunicado Indo-Pacifico"
     ),

   "Ensis_leei" = c(
    "Ensis leei",
    "Almeja navaja del Atlántico"
     ),

   "Marginella_glabella" = c(
    "Marginella glabella"
     ),

   "Sus_scrofa_var_domestica_raza_vietnamita" = c(
    "Sus scrofa var. domestica raza vietnamita",
    "Cerdo vietnamita",
    "Porc vietnamita",
    "Porco vietnamita",
    "Vietnamgo txerria"
     ),

   "Ferrissia_californica" = c(
    "Ferrissia californica",
    "Lapa de agua dulce americana",
    "Lapa de água doce americana"
     ),

   "Reticulitermes_flavipes" = c(
    "Reticulitermes flavipes",
    "Termita subterránea oriental",
    "Termita subterranea oriental",
    "Tèrmit subterrània oriental",
    "Termit subterrània oriental",
    "Cupim subterrâneo",
    "Cupim subterraneo"
     ),

   "Acizzia_jamatonica" = c(
    "Acizzia jamatonica",
    "Psila de la albicia",
    "Psilla dell'albizia",
    "Psyla de albizia",
    "Psyla de la albizia"
    ),

   "Acridotheres_cristatellus" = c(
    "Acridotheres cristatellus",
    "Mina moñudu",
    "Minà crestat",
    "Miná crestado",
    "Estornino crestado",
    "Mainá-de-crista",
    "Mainato cristado",
    "Mainá-de-crista",
    "Mainato-de-poupa",
    "Hartxori gangarduna"
    ),

   "Agapornis_nigrigenis" = c(
    "Agapornis nigrigenis",
    "Inseparable cachetón",
    "Inseparable de mejillas negras",
    "Agapornis musubeltza",
    "Agapornis musubeltz",
    "Agapornis galtanegre",
    "Inseparable galtanegre",
    "Agapornis de galtes negres",
    "Inseparable de galtes negres",
    "Inseparável-de-faces-pretas"
    ),

   "Amazona_albifrons" = c(
    "Amazona albifrons",
    "Amazona frentialba",
    "Amazona de front blanc",
    "Papagai frontblanc",
    "Amazona frontblanca",
    "Papagaio-de-testa-branca"
    ),

   "Amazona_farinosa" = c(
    "Amazona farinosa",
    "Papagai farinós",
    "Papagai farinós meridional",
    "Amazona harinosa",
    "Amazona farinosa",
    "Papagaio-moleiro",
    "Amazona farinosa meridional"
    ),

   "Amazona_ochrocephala" = c(
    "Amazona ochrocephala",
    "Amazona de front groc",
    "Amazona frontgroga",
    "Lloro de cap groc",
    "Lloro reial",
    "Lloro de corona groga",
    "Papagai de front gorc",
    "Amazona real",
    "Loro real amazónico",
    "Loro real amazonico",
    "Amazona de cabeza amarela",
    "Papagaio-campeiro",
    "Papagaio-de-coroa-amarela",
    "Amazona buruhoria",
    "Amazona de frente mariella",
    "Amazona frente mariella",
    "Amazona frente amarilla"
    ),

   "Amazonetta_brasiliensis" = c(
    "Amazonetta brasiliensis",
    "Pato brasileño",
    "Ànec del Brasil",
    "Marreca-de-pé-vermelho",
    "Marrequinha-brasileira",
    "Ahate brasildar",
    "Ahate brasildarra",
    "Pato Brasileiro"
    ),

   "Aratinga_leucophthalma" = c(
    "Aratinga leucophthalma",
    "Psittacara leucophthalmus",
    "Aratinga ojiblanca",
    "Cotorra ojiblanca",
    "Aratinga ullblanca",
    "Aratinga d'ulls blancs",
    "Periquitão-d'olho-branco"
    ),

   "Atheta_mucronata" = c(
    "Atheta mucronata"
    ),

   "Bemisia_tabaci" = c(
    "Bemisia tabaci",
    "Aleyrodes tabaci",
    "Mosca blanca",
    "Mosca blanca del tabaco",
    "Mosquita blanca del tabaco",
    "Mosca blanca del algodonero",
    "Mosca-branca",
    "Mosca blanca del tabacu",
    "Mosca-branca-do-tabaco",
    "Mosca blanca del tabac",
    "Mosca-branca da batata-doce"
    ),

   "Bursaphelenchus_xylophilus" = c(
    "Bursaphelenchus xylophilus",
    "Nematodo de la madera del pino",
    "Nematode de la fusta del pi",
    "Nematodo-da-madeira-do-pinheiro",
    "Pinuen nematodoaren gaitza",
    "Nematodo da madeira de piñeiro",
    "Nematodo de la madera de los pinos"
    ),

   "Ceratitis_capitata" = c(
    "Ceratitis capitata",
    "Mosca del Mediterráneo",
    "Mosca mediterránea de la fruta",
    "Mosca del Mediterraneo",
    "Mosca mediterranea de la fruta",
    "Mosca frutera del Mediterráneo",
    "Mosca frutera del Mediterraneo",
    "Mosca-das-frutas do mediterrâneo",
    "Mosca-das-frutas do mediterraneo",
    "Mosca-da-fruta do Mediterrâneo",
    "Mosca-da-fruta do Mediterraneo",
    "Mosca da froita mediterránea",
    "Mosca da froita mediterranea",
    "Mosca-do-mediterrâneo",
    "Mosca-do-mediterraneo",
    "Mosca rajada",
    "Mosca mediterrânica da fruta",
    "Mosca mediterranica da fruta",
    "Mosca mediterrània de la fruita",
    "Mosca mediterrania de la fruita",
    "Mosca mediterrânica de la fruita",
    "Mosca mediterranica de la fruita",
    "Mosca del Mediterrani"
    ),

   "Diadema_antillarum" = c(
    "Diadema antillarum",
    "Erizo de lima",
    "Erizo de mar negro",
    "Erizo de mar de espinas largas",
    "Ourizo de mar de espiñas longas",
    "Ouriço de espinhos longos",
    "Ouriço do mar de espinho longo",
    "Ouriço-do-mar de espinhos longos",
    "Eriçó de mar d'espines llargues",
    "Eriçó Diadema"
    ),

   "Drepanaphis_acerifoliae" = c(
    "Drepanaphis acerifoliae"
    ),

   "Drosophila_suzukii" = c(
    "Drosophila suzukii",
    "Drosófila de alas manchadas",
    "Drosófila de ala manchada",
    "Drosofila de alas manchadas",
    "Drosofila de ala manchada",
    "Mosca del vinagre de alas manchadas",
    "Mosca del vinagre alas manchadas",
    "Mosca-do-vinagre-de-asa-manchada",
    "Drosófila das asas manchadas",
    "Drosofila das asas manchadas",
    "Mosca d’ales tacades"
    ),

   "Eos_squamata" = c(
    "Eos squamata",
    "Lori ventrenegre",
    "Lori collar violeta",
    "Lori escamoso",
    "Lóris de colar violeta",
    "Loris de colar violeta",
    "Lóri-de-pescoço-violeta",
    "Lori-de-pescoço-violeta",
    "Lori de collar violeta",
    "Lori de collaret violeta"
    ),

   "Euplectes_macroura" = c(
    "Euplectes macroura",
    "Obispo dorsiamarillo",
    "Bisbe de dors groc",
    "Teixidor d'espatlles grogues",
    "Bispo-de-dorso-amarelo",
    "Viúva-de-manto-amarelo",
    "Bispo-de-manto-amarelo",
    "Bisbe dorsigroc",
    "Euplekte sorbaldahori",
    "Euplekte sorbaldahoria"
    ),

   "Paratrechina_vividula" = c(
    "Paratrechina vividula"
    ),

   "Pionites_melanocephalus" = c(
    "Pionites melanocephalus",
    "Caique de cabeza negra",
    "Cherlicres",
    "Lloro capnegre",
    "Caique de cap negre",
    "Lorito chirlecrés",
    "Marianinha de cabeça preta",
    "Papagaio-de-barrete-preto"
    ),

   "Poicephalus_crassus" = c(
    "Poicephalus crassus",
    "Lloro niam niam",
    "Lloro niam-niam",
    "Lloro nyam-nyam",
    "Lorito nianiam",
    "Papagaio de niam-niam"
    ),

   "Primolius_maracana" = c(
    "Primolius maracana",
    "Guacamayo maracaná",
    "Guacamayo maracana",
    "Guacamayo de Illiger",
    "Guacamayo de cara afeitada",
    "Guacamayo cara afeitada",
    "Guacamai alablau",
    "Arara d'asa azul",
    "Maracanã-verdadeiro",
    "Arara de Illiger"
    ),

   "Scyphophorus_acupunctatus" = c(
    "Scyphophorus acupunctatus",
    "Picudo del agave",
    "Gorgojo del agave",
    "Picudo negro del agave",
    "Morrut negre",
    "Morrut de l’atzavara",
    "Morrut de les atzavares",
    "Morrut de atzavares",
    "Escaravelho-do-Agave",
    "Gorgulho de agave",
    "Gorgojo do agave"
    ),

   "Thaumastocoris_peregrinus" = c(
    "Thaumastocoris peregrinus",
    "Chinche del eucalipto",
    "Xinxa de l'eucaliptus",
    "Percevejo-do-bronzeamento",
    "Percevejo-bronzeado-do-eucalipto",
    "Percevejo-bronzeado"
    ),

   "Rugulopteryx_okamurae" = c(
    "Rugulopteryx okamurae",
    "Alga asiática",
    "Algas asiáticas",
    "Alga asiatica",
    "Algas asiaticas",
    "Alga invasora asiática",
    "Alga asiática invasora",
    "Alga asiatica invasora"
    ),

   "Halimeda_incrassata" = c(
    "Halimeda incrassata"
    ),

   "Aplidium_accarens" = c(
    "Aplidium accarense"
    ),

   "Epichrysocharis_burwelli" = c(
    "Epichrysocharis burwelli"
    ),

   "Ophelimus_maskelli" = c(
    "Ophelimus maskelli"
    ),

   "Tenellia_adspersa" = c(
    "Tenellia adspersa"
    ),

   "Chrysonephos_lewisii" = c(
    "Chrysonephos lewisii"
    ),

   "Crassula_helmsii" = c(
    "Crassula helmsii",
    "Crásula de agua",
    "Crasula de agua",
    "Crásula acuática",
    "Crásula acuatica",
    "Crasula acuática",
    "Crasula acuatica"
    ),

   "Molgula_manhattensis" = c(
    "Molgula manhattensis",
    "Raïm de (la) mar",
    "Raïm de mar",
    "Raïm marí",
    "Raïm mari"
    ),

   "Paracerceis_sculpta" = c(
    "Paracerceis sculpta",
    "Isópodo esculpido",
    "Isopodo esculpido"
    ),

   "Amathia_verticillata" = c(
    "Amathia verticillata",
    "Briozoo espagueti",
    "Espaguete bryozoo"
    ),

   "Ficopomatus_enigmaticus" = c(
     "Ficopomatus enigmaticus",
     "Poliqueto constructor de arrecifes calcáreos",
     "Poliqueto constructor de arrecifes calcareos",
     "Gusano formador de arrecifes"
    ),

   "Caprella_mutica" = c(
     "Caprella mutica",
     "Camarón esqueleto japonés",
     "Camarón esquelet japonès",
     "Camarón esqueleto xaponés",
     "Camarón esqueleto japones",
     "Camarón esquelet japones",
     "Camarón esqueleto xapones",
     "Camaron esqueleto japonés",
     "Camaron esquelet japonès",
     "Camaron esqueleto xaponés",
     "Camaron esqueleto japones",
     "Camaron esquelet japones",
     "Camaron esqueleto xapones",
     "Camarão esqueleto japonês",
     "Camarão esqueleto japones"
    ),

   "Maize_chlorotic_mottle_virus" = c(
     "Maize chlorotic mottle virus",
     "Virus del moteado clorótico del maíz",
     "Vírus do Mosqueado Clorótico do Milho",
     "Vírus da mancha clorótica do milho",
     "Virus del moteado clorotico del maíz",
     "Vírus do Mosqueado Clorotico do Milho",
     "Vírus da mancha clorotica do milho",
     "Virus del moteado clorótico del maiz",
     "Virus del moteado clorotico del maíz",
     "Virus del moteado clorotico del maiz"
    ),

   "Sweet_potato_virus_C" = c(
     "Sweet potato virus C",
     "Virus C de la batata",
     "Vírus da batata doce C",
     "Vírus C da batata-doce",
     "Vírus C da batata-doce",
     "Vírus da batata-doce"
    ),

   "Synoicus_chinensis" = c(
     "Synoicus chinensis",
     "Codorniz china",
     "Guatlla blava asiàtica",
     "Guatlla blava asiatica",
     "Codorniz chinesa"
    ),

   "Tomato_leaf_curl_New_Delhi_virus" = c(
     "Tomato leaf curl New Delhi virus",
     "Virus del rizado amarillo del tomate de Nueva Delhi",
     "Virus del rizado de la hoja del tomate de Nueva Delhi",
     "Virus del enrollado amarillo del tomate de Nueva Delhi",
     "Virus del rizado del tomate de Nueva Delhi",
     "Virus de Nueva Delhi",
     "Virus de l'arrissat del tomàquet de Nova Delhi",
     "Virus de l'arrissat groc del tomàquet de Nova Delhi",
     "Virus de Nova Delhi",
     "Vírus de onda amarela do tomate de Nova Delhi",
     "Vírus enrolado da folha do tomate Nova Delhi",
     "ToLCNDV"
    ),

   "Tomato_mottle_mosaic_virus" = c(
     "Tomato mottle mosaic virus",
     "Virus del mosaico moteado del tomate",
     "Virus del mosaico del moteado",
     "Virus del moteado leve del tomate"
    ),

   "Phytophthora_citricola" = c(
     "Phytophthora citricola",
     "Aguado en cítricos",
     "Aguado de los cítricos",
     "Aguado cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Podredumbre radicular de cítricos",
     "Podredumbre radicular de los cítricos",
     "Aguado en citricos",
     "Aguado de los citricos",
     "Aguado citricos",
     "Pudrición marrón de los citricos",
     "Podredumbre marrón de los citricos",
     "Podedumbre marrón en los citricos",
     "Podredumbre marrón en citricos",
     "Podredumbre radicular de citricos",
     "Podredumbre radicular de los citricos",
     "Pudrición marron de los cítricos",
     "Podredumbre marron de los cítricos",
     "Podedumbre marron en los cítricos",
     "Podredumbre marron en cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Aigualit dels cítrics"
    ),

   "Rapana_venosa" = c(
     "Rapana venosa",
     "Busano veteado",
     "Buche de rapa",
     "Caracol venoso"
    ),

   "Tritia_mutabilis" = c(
     "Tritia mutabilis",
     "Mugarida lisa",
     "Cornet d’arenal",
     "Margarida llisa",
     "Cargolí Blanc",
     "Cargolí Margarida",
     "Cargoli Blanc",
     "Cargoli Margarida"
    ),

   "Harmonia_axyridis" = c(
     "Harmonia axyridis",
     "Mariquita asiática multicolor",
     "Mariquita asiática",
     "Mariquita arlequín",
     "Marieta asiàtica multicolor",
     "Marieta asiàtica",
     "Marieta arlequí",
     "Xoaniña asiática multicor",
     "Xoaniña asiática",
     "Xoaniña da China",
     "Xoaniña arlequín",
     "Arlekin marigorringoa",
     "Joaninha asiática multicolorida",
     "Joaninha asiática",
     "Mariquita asiatica multicolor",
     "Mariquita asiatica",
     "Mariquita arlequin",
     "Marieta asiatica multicolor",
     "Marieta asiatica",
     "Marieta arlequi",
     "Xoaniña asiatica multicor",
     "Xoaniña asiatica",
     "Xoaniña asiatica",
     "Xoaniña da China",
     "Xoaniña arlequin",
     "Joaninha asiatica multicolorida",
     "Joaninha asiatica",
     "Joaninha arlequim"
    ),

   "Psephotus_haematonotus" = c(
     "Psephotus haematonotus",
     "Rabadilla roja",
     "Periquito de rabadilla roja",
     "Periquito rabadilla roja",
     "Perico dorsirrojo",
     "Perico de rabadilla roja",
     "Perico rabadilla roja",
     "Periquito dorsirrojo",
     "Cotorra de carpó roig",
     "Cotorra de carpo roig",
     "Cotorra de dors roig",
     "Perico carpó-roig",
     "Perico carpo-roig",
     "Periquito-d'uropígio-vermelho"
    ),

   "Pycnonotus_jocosus" = c(
     "Pycnonotus jocosus",
     "Bulbul orfeo",
     "Bulbul de bigoti vermell",
     "Bulbul orfeu",
     "Bulbul de bigot roig",
     "Bulbul de faceiras vermellas",
     "Bulbul de meixelas brancas",
     "Bulbul masailgorri",
     "Bulbul moñuzu",
     "Bulbul-de-faces-vermelhas"
    ),

   "Axonopus_fissifolius" = c(
     "Axonopus fissifolius",
     "Hierba de alfombra común",
     "Hierba de alfombra comun",
     "Grama brasilera"
    ),

   "Pyura_herdmani" = c(
     "Pyura herdmani",
     "Cebo rojo africano"
    ),

   "Cydalima_perspectalis" = c(
     "Cydalima perspectalis",
     "Polilla del boj",
     "Piral del boj",
     "Eruga del boix",
     "Eruga defoliadora del boix",
     "Papallona del boix",
     "Palometa del boix",
     "Avelaíña do buxo",
     "Ezpel sits",
     "Ezpel sitsa"
    ),

   "Megachile_sculpturalis" = c(
     "Megachile sculpturalis",
     "Abeja gigante de la resina",
     "Abeja invasora escultórica",
     "Abeja invasora escultorica",
     "Abella gegant de la resina",
     "Abella xigante de resina"
    ),

   "Wasmannia_auropunctata" = c(
     "Wasmannia auropunctata",
     "Hormiga eléctrica",
     "Hormiga electrica",
     "Hormiguita de fuego",
     "Pequeña hormiga de fuego",
     "Hormiga pequeña de fuego",
     "Formiga de foc roja",
     "Formigueta de foc",
     "Petita formiga de foc",
     "Formiga petita de foc",
     "Formiguiña de lume",
     "Formiga electrica",
     "Formiga elèctrica"
    ),

   "Mauremys_reevesii" = c(
     "Mauremys reevesii",
     "Tortuga china de estanque",
     "Tortuga de estanque china",
     "Tortuga china de tres crestas",
     "Tortuga china crestada",
     "Tortuga crestada china",
     "Tortuga de tres crestas",
     "Galápago chino de tres crestas",
     "Galapago chino de tres crestas",
     "Tortuga d'estany xinesa",
     "Tortuga d'aigua xinesa",
     "Tortuga xinesa de tres quilles",
     "Sapoconcho chinés de tres quillas",
     "Sapoconcho chines de tres quillas",
     "Sapoconcho de tres quillas",
     "Tartaruga-chinesa-de-tres-quillas",
     "Tartaruga de estanque chinesa",
     "Tartaruga chinesa de três quilhas"
    ),

   "Mauremys_sinensis" = c(
     "Mauremys sinensis",
     "Galápago chino de cuello estriado",
     "Tortuga de cuello rayado",
     "Tortuga china de cuello rayado",
     "Tortuga china cuello rayado",
     "Tortuga cuello rayado china",
     "Tortuga cuello rayado",
     "Tortuga de cuello rallado",
     "Tortuga china de cuello rallado",
     "Tortuga de cuello estriado",
     "Tortuga de cuello con franjas",
     "Tortuga Ocadia",
     "Tortuga de coll ratllat",
     "Tortuga xinesa de coll ratllat",
     "Sapoconcho de pescozo listado",
     "Tartaruga de pescozo con franxas",
     "Tartaruga-chinesa-de-pescoço-listado",
     "Tartaruga chinesa de pescoço listrado",
     "Tartaruga-de-pescoço-listrado-chinesa",
     "Tartaruga chinesa de pescoço às riscas"
    ),

   "Ludwigia_peploides" = c(
     "Ludwigia peploides",
     "Duraznillo de agua",
     "Onagraria",
     "Enramada de las tarariras"
    ),

   "Pseudemys_peninsularis" = c(
     "Pseudemys peninsularis",
     "Tortuga de la península",
     "Galápago peninsular",
     "Tortuga de la peninsula",
     "Galapago peninsular"
    ),

   "Spodoptera_frugiperda" = c(
     "Spodoptera frugiperda",
     "Gusano cogollero",
     "Cogollero del maíz",
     "Gusano cogollero del maíz",
     "Oruga cogollera del maíz",
     "Oruga militar tardía",
     "Cogollero del maiz",
     "Gusano cogollero del maiz",
     "Oruga cogollera del maiz",
     "Oruga militar tardia",
     "Cuc cogoller",
     "Oruga militar tardana",
     "Verme-cogollero-do-millo",
     "Lagarta-do-cartucho"
    ),

   "Halyomorpha_halys" = c(
     "Halyomorpha halys",
     "Chinche parda marmorada",
     "Chinche hedionda marrón marmoleada",
     "Chinche apestosa marrón marmolada",
     "Chinche apestoso marrón mármol",
     "Chinche apestoso marron mármol",
     "Chinche apestosa marrón",
     "Chinche apestoso marrón",
     "Chinche hedionda marron marmoleada",
     "Chinche apestosa marron marmolada",
     "Chinche apestoso marron mármol",
     "Chinche apestoso marron marmol",
     "Chinche apestosa marron",
     "Chinche apestoso marron",
     "Chinche apestosa",
     "Chinche hedionda",
     "Bernat marbrejat",
     "Bernat marbrat marró",
     "Bernat marbrat marro",
     "Armarri zimitz jaspeztatua",
     "Zimitz kirasdun marroia",
     "Percevejo marrom marmoreado",
     "Percevejo-asiático",
     "Percevejo-asiatico",
     "Percevejo-fedorento marrom marmorizado"
    ),

   "Aedes_aegypti" = c(
     "Aedes aegypti",
     "Mosquito del dengue",
     "Mosquito momia",
     "Mosquito de la fiebre amarilla",
     "Mosquito africano de la fiebre amarilla",
     "Mosquit del dengue",
     "Mosquit de la febre groga",
     "Mosquito da dengue",
     "Sukar horiaren eltxoak",
     "Mosquito da dengue",
     "Pernilongo rajado"
    ),

   "Euwallacea_fornicatus" = c(
     "Euwallacea fornicatus",
     "Barrenador polígafo",
     "Barrenillo del té",
     "Escarabajo barrenillo del té",
     "Escarabajo barrenador polígafo",
     "Broca-de-tiro-do-chá",
     "Broca-de-tiro-polífaga",
     "Barrenador poligafo",
     "Barrenillo del te",
     "Escarabajo barrenillo del te",
     "Escarabajo barrenador poligafo",
     "Broca-de-tiro-do-cha",
     "Broca-de-tiro-polifaga"
    ),

   "Procambarus_virginalis" = c(
     "Procambarus virginalis",
     "Cangrejo mármol",
     "Cangrejo de mármol",
     "Cangrejo marmol",
     "Cangrejo de marmol",
     "Cangrejo marmoleado",
     "Marmorkrebs"
    ),

   "Cherax_quadricarinatus" = c(
     "Cherax quadricarinatus",
     "Langosta australiana azul",
     "Langosta de agua dulce",
     "Langosta de agua dulce australiana",
     "Langosta de agua dulce de pinzas rojas",
     "Langosta azul",
     "Langosta de río australiana",
     "Langosta de rio australiana",
     "Langosta azul australiana",
     "Yabby azul",
     "Llagosta blava",
     "Llagosta blava australiana",
     "Llagosta autraliana d'aigua dolça",
     "Llagosta d'aigua dolça australiana",
     "Lagosta azul australiana",
     "Lagosta de água doce",
     "Lagosta de água doce australiana",
     "Lagosta de agua doce",
     "Lagosta de agua doce australiana"
    ),

   "Xylella_fastidiosa" = c(
     "Xylella fastidiosa",
     "Xilel la",
     "Xilel·la"
    ),

   "Tobamovirus_fructirugosum" = c(
     "Tobamovirus fructirugosum",
     "Virus del fruto rugoso marrón del tomate",
     "Virus del fruto rugoso marron del tomate",
     "Virus rugoso del tomate",
     "Virus del fruto pardo y rugoso del tomate"
    )

)


# Assuming your list is named all_lists_common_NEW_ES_PT_regioncode_common_only

# Extract names and replace underscores with spaces
species_names <- names(all_lists_common_NEW_ES_PT_regioncode_common_only)
species_names_clean <- gsub("_", " ", species_names)

# View the cleaned species names
print(species_names_clean)

# Optionally, save as a data frame
species_df <- data.frame(Species = species_names_clean)

# If you want to export to CSV
# write.csv(species_df, "species_searched.csv", row.names = FALSE)


########################################################################### PREPARE THE DATASET (MATCHES OF SEARCH TERMS WITH ALL SP NAMES ##################################################################

library(data.table)
library(stringi) # For text normalization

# Function to normalize text (remove accents and convert to lowercase)
normalize_text <- function(text) {
  stri_trans_general(stri_trim(text), "Latin-ASCII") # Convert accents to ASCII equivalent
}

# Convert dataset to data.table if not already
setDT(final_region_regioncode_common_only_dedup)



# === Step 1: Create Lookup Table from `all_lists_common_NEW_ES_PT_regioncode_common_only` ===
lookup_table <- data.table(
  common_NEW_ES_PT_regioncode_common_only_name = unlist(all_lists_common_NEW_ES_PT_regioncode_common_only, use.names = FALSE),
  unique_species = rep(names(all_lists_common_NEW_ES_PT_regioncode_common_only), times = sapply(all_lists_common_NEW_ES_PT_regioncode_common_only, length))
)

# Normalize text in lookup table
lookup_table[, common_NEW_ES_PT_regioncode_common_only_name := normalize_text(common_NEW_ES_PT_regioncode_common_only_name)]

# Remove duplicates to avoid multiple mappings
lookup_table <- unique(lookup_table, by = "common_NEW_ES_PT_regioncode_common_only_name")

# === Step 2: Normalize Species Names in the Main Dataset ===
final_region_regioncode_common_only_dedup[, species_normalized := normalize_text(query)]

# Ensure both columns are characters (avoiding potential factor issues)
lookup_table[, common_NEW_ES_PT_regioncode_common_only_name := as.character(common_NEW_ES_PT_regioncode_common_only_name)]
final_region_regioncode_common_only_dedup[, species_normalized := as.character(species_normalized)]


# === Step 3: Perform the Merge ===
final_region_regioncode_common_only_dedup <- merge(
  final_region_regioncode_common_only_dedup,
  lookup_table,
  by.x = "species_normalized",
  by.y = "common_NEW_ES_PT_regioncode_common_only_name",
  all.x = TRUE,
  allow.cartesian = TRUE
)


unique(final_region_regioncode_common_only_dedup$unique_species)

  [1] "Megachile_sculpturalis"                   "Phoeniculus_purpureus"                    "Agapornis_fischeri"                      
  [4] "Phytophthora_citricola"                   "Geranoaetus_melanoleucus"                 "Haliaeetus_leucocephalus"                
  [7] "Rugulopteryx_okamurae"                    "Amazona_amazonica"                        "Amazona_ochrocephala"                    
 [10] "Amazona_albifrons"                        "Anser_cygnoides"                          "Aratinga_leucophthalma"                  
 [13] "Leuciscus_aspius"                         "Vanellus senegallus"                      "Vespa_velutina"                          
 [16] "Dryocosmus_kuriphilus"                    "Vespa_orientalis"                         "Vespa_soror"                             
 [19] "Ictalurus_punctatus"                      "Platycerium_bifurcatum"                   "Branta_canadensis"                       
 [22] "Halyomorpha_halys"                        "Pycnonotus_jocosus"                       "Geranoaetus_polyosoma"                   
 [25] "Pionites_melanocephalus"                  "Tockus_deckeni"                           "Rhodospiza_obsoleta"                     
 [28] "Haemorhous_mexicanus"                     "Procambarus_virginalis"                   "Lonchura_oryzivora"                      
 [31] "Caracara_plancus"                         "Pomacea_maculata"                         "Rapana_venosa"                           
 [34] "Cardiocondyla_obscurior"                  "Carassius_gibelio"                        "Chloephaga_picta"                        
 [37] "Anas_flavirostris"                        "Sus_scrofa_var_domestica_raza_vietnamita" "Leptoglossus_occidentalis"               
 [40] "Thaumastocoris_peregrinus"                "Pluchea_carolinensis"                     "Zebrasoma_flavescens"                    
 [43] "Cygnus_melancoryphus"                     "Synoicus_chinensis"                       "Spodoptera_frugiperda"                   
 [46] "Platalea_ajaja"                           "Columbina_talpacoti"                      "Glycaspis_brimblecombei"                 
 [49] "Corvus_albus"                             "Delottococcus_aberiae"                    "Aratinga_jandaya"                        
 [52] "Mnemiopsis_leidyi"                        "Reticulitermes_flavipes"                  "Ludwigia_peploides"                      
 [55] "Elanoides_forficatus"                     "Diadema_antillarum"                       "Cydalima_perspectalis"                   
 [58] "Acridotheres_cristatellus"                "Paratrechina_jaegerskioeldi"              "Tapinoma_melanocephalum"                 
 [61] "Caprella_scaura"                          "Cereopsis_novaehollandiae"                "Scyphophorus_acupunctatus"               
 [64] "Axonopus_fissifolius"                     "Grus_canadensis"                          "Primolius_maracana"                      
 [67] "Phthorimaea_absoluta"                     "Wasmannia_auropunctata"                   "Pheidole_megacephala"                    
 [70] "Brachymyrmex_patagonicus"                 "Agapornis_nigrigenis"                     "Harmonia_axyridis"                       
 [73] "Cherax_quadricarinatus"                   "Psittacus_erithacus"                      "Primolius_auricollis"                    
 [76] "Amazonetta_brasiliensis"                  "Acridotheres_ginginianus"                 "Varanus_exanthematicus"                  
 [79] "Bemisia_tabaci"                           "Ceratitis_capitata"                       "Drosophila_suzukii"                      
 [82] "Aedes_japonicus"                          "Aedes_aegypti"                            "Bursaphelenchus_xylophilus"              
 [85] "Caloenas_nicobarica"                      "Zenaida_meloda"                           "Amazona_farinosa"                        
 [88] "Styela_plicata"                           "Balistoides_conspicillum"                 "Dyspanopeus_sayi"                        
 [91] "Perca_fluviatilis"                        "Psephotus_haematonotus"                   "Neophema_pulchella"                      
 [94] "Lagocephalus_sceleratus"                  "Aphis_illinoisensis"                      "Sipha_flava"                             
 [97] "Epitrix_similaris"                        "Mauremys_reevesii"                        "Graptemys_pseudogeographica"             
[100] "Pseudemys_concinna"                       "Testudo_marginata"                        "Apalone_ferox"                           
[103] "Pelodiscus_sinensis"                      "Tomato_leaf_curl_New_Delhi_virus"         "Mauremys_sinensis"                       
[106] "Pseudemys_peninsularis"                   "Trachemys_emolli"                         "Tobamovirus_fructirugosum"               
[109] "Xylella_fastidiosa"  


# Ensure your dataset is a data.table
setDT(final_region_regioncode_common_only_dedup)

# Count number of rows (videos) per unique_species
species_counts_common_NEW_ES_PT_regioncode_common_only <- final_region_regioncode_common_only_dedup[, .N, by = unique_species][order(-N)]

# View top species by video count
print(species_counts_common_NEW_ES_PT_regioncode_common_only)

   unique_species     N
                       <char> <int>
  1:           Vespa_velutina   535
  2:      Psittacus_erithacus   534
  3: Geranoaetus_melanoleucus   322
  4: Haliaeetus_leucocephalus   300
  5:          Anser_cygnoides   286
 ---                               
105:       Drosophila_suzukii     1
106:           Styela_plicata     1
107:         Dyspanopeus_sayi     1
108:   Pseudemys_peninsularis     1
109:         Trachemys_emolli     1


--------------################ DATASET WITH SPECIES WITH 0 SEARCH RESULTS ###############

# ? All species you searched for (from your lookup list)
all_species_common_NEW_ES_PT_regioncode_common_only <- names(all_lists_common_NEW_ES_PT_regioncode_common_only)

# ? Species actually matched in the YouTube results
included_species_common_NEW_ES_PT_regioncode_common_only <- unique(final_region_regioncode_common_only_dedup$unique_species)

# ? Find species that were NOT included (i.e., no search results)
missing_species_common_NEW_ES_PT_regioncode_common_only <- setdiff(all_species_common_NEW_ES_PT_regioncode_common_only, included_species_common_NEW_ES_PT_regioncode_common_only)

# ? View the missing species
missing_species_common_NEW_ES_PT_regioncode_common_only

[1] "Eupsittula_pertinax"          "Spatula_hottentota"           "Barbronia_weberi"             "Blastopsylla_occidentalis"   
 [5] "Chenonetta_jubata"            "Crangonyx_pseudogracilis"     "Gobio_occitaniae"             "Equisetum_palustre"          
 [9] "Lorius_chlorocercus"          "Macrochelys_temminckii"       "Maeotias_marginata"           "Marisa_cornuarietis"         
[13] "Microlepia_platyphylla"       "Mimus_gilvus"                 "Musophaga_violacea"           "Netta_peposaca"              
[17] "Obolodiplosis_robiniae"       "Orientogalba viridis"         "Ommatotriton_ophryticus"      "Palaemon_macrodactylus"      
[21] "Psyllaephagus_bliteus"        "Stenopelmus_rufinasus"        "Lepisiota_capensis"           "Neotoxoptera_formosana"      
[25] "Puto_barberi"                 "Camponotus_compressus"        "Epidiplosis_filifera"         "Penthimiola_bella"           
[29] "Schizoporella_errata"         "Stenothoe_georgiana"          "Hercinothrips_dimidiatus"     "Hydrocharis_laevigata"       
[33] "Bosmina_coregoni"             "Hypoponera_ergatandria"       "Lobiopa_insularis"            "Chrysonotomyia_chamaeleon"   
[37] "Pezothrips_kellyanus"         "Sophonia_orientalis"          "Lasius_neglectus"             "Pheidole_indica"             
[41] "Strumigenys_silvestrii"       "Anoplolepis_gracilipes"       "Planorbella_duryi"            "Pseudosuccinea_columella"    
[45] "Pseudodiaptomus_marinus"      "Faxonius_limosus"             "Hemicypris_barbadensis"       "Hemicypris_reticulata"       
[49] "Belonochilus_numenius"        "Brachymyrmex_heeri"           "Blechnum_occidentale"         "Tapinoma_pallipes"           
[53] "Duttaphrynus_melanostictus"   "Vespa_bicolor"                "Trachymela_sloanei"           "Xylotrechus_chinensis"       
[57] "Paracoccus_burnerae"          "Macrohomotoma_gladiata"       "Paracaprella_pusilla"         "Megabalanus_tintinnabulum"   
[61] "Solidobalanus_fallax"         "Psilopsiagon_aymara"          "Bycanistes_brevis"            "Theora_lubrica"              
[65] "Atriplex_semilunaris"         "Eucheilota_menoni"            "Branchiomma_bairdi"           "Perinereis_linea"            
[69] "Perophora_japonica"           "Ensis_leei"                   "Marginella_glabella"          "Ferrissia_californica"       
[73] "Acizzia_jamatonica"           "Atheta_mucronata"             "Drepanaphis_acerifoliae"      "Eos_squamata"                
[77] "Euplectes_macroura"           "Paratrechina_vividula"        "Poicephalus_crassus"          "Halimeda_incrassata"         
[81] "Aplidium_accarens"            "Epichrysocharis_burwelli"     "Ophelimus_maskelli"           "Tenellia_adspersa"           
[85] "Chrysonephos_lewisii"         "Crassula_helmsii"             "Molgula_manhattensis"         "Paracerceis_sculpta"         
[89] "Amathia_verticillata"         "Ficopomatus_enigmaticus"      "Caprella_mutica"              "Maize_chlorotic_mottle_virus"
[93] "Sweet_potato_virus_C"         "Tomato_mottle_mosaic_virus"   "Tritia_mutabilis"             "Pyura_herdmani"              
[97] "Euwallacea_fornicatus"    


# Vector of missing species
missing_species_common_NEW_ES_PT_regioncode_common_only <- c(
 "Barbronia_weberi",           "Blastopsylla_occidentalis",  "Chenonetta_jubata",          "Crangonyx_pseudogracilis",   "Gobio_occitaniae",
 "Equisetum_palustre",         "Maeotias_marginata",         "Trachemys_emolli",           "Lepisiota_capensis",         "Neotoxoptera_formosana",
 "Puto_barberi",               "Glycaspis_brimblecombei",    "Lasius_neglectus",           "Anoplolepis_gracilipes",    "Pseudosuccinea_columella",
 "Faxonius_limosus",           "Duttaphrynus_melanostictus", "Xylotrechus_chinensis",      "Macrohomotoma_gladiata",     "Dyspanopeus_sayi",
 "Megabalanus_tintinnabulum",  "Perophora_japonica",         "Ensis_leei",                 "Reticulitermes_flavipes",    "Acizzia_jamatonica",
 "Euplectes_macroura",         "Poicephalus_crassus",        "Vespa_bicolor"
)

# Normalize function (like before)
normalize_text <- function(text) stri_trans_general(stri_trim(text), "Latin-ASCII")

# Normalize search terms in the combined dataset
final_region_regioncode_common_only_dedup$search_term_normalized <- normalize_text(final_region_regioncode_common_only_dedup$search_term)

# Normalize the scientific names (remove underscores and lowercase)
normalized_missing_species_common_NEW_ES_PT_regioncode_common_only <- tolower(gsub("_", " ", missing_species_common_NEW_ES_PT_regioncode_common_only))
normalized_missing_species_common_NEW_ES_PT_regioncode_common_only <- normalize_text(normalized_missing_species_common_NEW_ES_PT_regioncode_common_only)

# Check which species DO appear in search_term
matching_species_common_NEW_ES_PT_regioncode_common_only <- unique(
  final_region_regioncode_common_only_dedup$search_term_normalized[
    final_region_regioncode_common_only_dedup$search_term_normalized %in% normalized_missing_species_common_NEW_ES_PT_regioncode_common_only
  ]
)

# View results
cat("? These missing species WERE found in 'final_region_regioncode_common_only_dedup':\n")
print(matching_species_common_NEW_ES_PT_regioncode_common_only)

# Optionally, show which were truly missing
truly_missing_common_NEW_ES_PT_regioncode_common_only <- setdiff(normalized_missing_species_common_NEW_ES_PT_regioncode_common_only, matching_species_common_NEW_ES_PT_regioncode_common_only)

cat("\n? These species are completely absent (not even searched):\n")
print(truly_missing_common_NEW_ES_PT_regioncode_common_only)


# Add the "created_at" column as a copy of "published"
final_region_regioncode_common_only_dedup <- final_region_regioncode_common_only_dedup %>%
  mutate(created_at = publishedAt)

# Verify the new column is added and matches the "published" column
head(final_region_regioncode_common_only_dedup[, c("publishedAt", "created_at")])


final_region_regioncode_common_only_dedup <- as.data.table(final_region_regioncode_common_only_dedup)
#subset_Aedes_japonicus <- youtube_recent_all_post[youtube_recent_all_post$species_name == "Aedes japonicus",]

# Get unique species names
unique_species <- unique(final_region_regioncode_common_only_dedup$unique_species)

# Rename 'unique_species' to 'TaxonName' in final_region_regioncode_common_only_dedup
final_region_regioncode_common_only_dedup <- final_region_regioncode_common_only_dedup %>%
  rename(TaxonName = unique_species)


####################################################################################### ADDING FIRST ZENODO INFORMATION TO THE FORMATTED DATASET ###########################################################

# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(cld2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)
library(officer)


# Read the Excel file
zenodo_sp_list <- read_excel("Recent_Intros_IP_All_for_table_v31_SP_NAMES_UPDATED_cleaned_rev_loc_filters.xlsx")

# Step 1: Clean LifeForm names
zenodo_sp_list <- zenodo_sp_list %>%
  mutate(
    LifeForm = as.character(LifeForm),
    LifeForm = recode(LifeForm,
      "Invertebrates (excl. Arthropods, Molluscs)" = "Non-arthropod invertebrates"
    )
  )

# Step 2: Replace NA in PresentStatus with "uncertain"
zenodo_sp_list$PresentStatus[is.na(zenodo_sp_list$PresentStatus)] <- "uncertain"

# Step 3: Group taxa categories
zenodo_grouped <- zenodo_sp_list %>%
  mutate(
    LifeForm = case_when(
      LifeForm %in% c("Vascular plants", "Algae", "Bryozoa") ~ "Plants",
      LifeForm %in% c("Molluscs") ~ "Non-arthropod invertebrates",
      LifeForm %in% c("Amphibians", "Reptiles") ~ "Herptiles",
      LifeForm %in% c("Viruses","Fungi") ~ "Bacteria, Viruses, Fungi",
      TRUE ~ LifeForm
    )
  ) %>%
  filter(LifeForm != "Mammals")  # Remove group with only 1 species

# Step 4: Summarise unique species
summary_table <- zenodo_grouped %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(
    names_from = PresentStatus,
    values_from = n_species,
    values_fill = 0
  )

# Step 5: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% colnames(summary_table)) {
    summary_table[[col]] <- 0
  }
}

# Step 6: Add totals
summary_table <- summary_table %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 7: Add total row
total_row <- summary_table %>%
  summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = sum(percentage)
  )

summary_table_final_region_regioncode_common_only <- bind_rows(summary_table, total_row) %>%
  arrange(desc(total_species))

# Step 8: Export to CSV
write.csv(summary_table_final_region_regioncode_common_only, "summary_species_by_lifeform_with_total.csv", row.names = FALSE)

# Step 9: Export to Word (DOCX)
ft <- summary_table_final_region_regioncode_common_only %>%
  flextable() %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

read_docx() %>%
  body_add_par("Summary of Species per Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(ft) %>%
  print(target = "summary_species_by_lifeform_with_total.docx")



# Define the priority order of PresentStatus
status_priority <- c("alien", "established", "casual", "uncertain")

# Convert PresentStatus to a factor with ordered levels
zenodo_cleaned <- zenodo_grouped %>%
  mutate(PresentStatus = factor(PresentStatus, levels = status_priority, ordered = TRUE))

# Apply filtering
zenodo_filtered <- zenodo_cleaned %>%
  group_by(TaxonName) %>%
  filter(FirstRecord == min(FirstRecord)) %>%   # Keep only rows with the minimum year
  slice_min(PresentStatus, with_ties = FALSE) %>% # Break ties using PresentStatus priority
  ungroup()

# View result
print(zenodo_filtered)


# 1. Fix TaxonName formatting + Region in zenodo_filtered
zenodo_filtered <- zenodo_filtered %>%
  mutate(
    TaxonName = str_replace_all(TaxonName, " ", "_"),
    Region_all = case_when(
      Region %in% c("Portugal", "Azores", "Madeira") ~ "Portugal",
      Region %in% c("Spain", "Canary Islands", "Andorra") ~ "Spain",
      TRUE ~ NA_character_
    )
  )

# 2. Detect language from combined text fields in video dataset
final_region_regioncode_common_only_dedup <- final_region_regioncode_common_only_dedup %>%
  mutate(
    text_combined = paste(
      ifelse(is.na(description), "", description),
      ifelse(is.na(title), "", title),
      ifelse(is.na(search_term), "", search_term)
    ),
    lang_detected = cld2::detect_language(text_combined, plain_text = TRUE),
    Region_all = case_when(
      lang_detected == "pt" ~ "Portugal",
      lang_detected %in% c("es", "ca", "gl", "eu", "ast") ~ "Spain",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-text_combined)  # drop helper column


# 3. Final merge on corrected TaxonName + Region_all
#combined_data_common_NEW_ES_PT_regioncode_common_only <- final_region_regioncode_common_only_dedup %>%
#  left_join(zenodo_filtered, by = c("TaxonName"))

library(dplyr)
library(tidyr)
library(flextable)
library(officer)

# Step 1: Replace NA in PresentStatus with "uncertain"
zenodo_filtered$PresentStatus[is.na(zenodo_filtered$PresentStatus)] <- "uncertain"

# Step 2: Create summary table of species by LifeForm and PresentStatus
summary_table <- zenodo_filtered %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = n_species, values_fill = 0)

# Step 3: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% names(summary_table)) summary_table[[col]] <- 0
}

# Step 4: Add total species and % of total
summary_table <- summary_table %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 5: Add total row
total_row <- summary_table %>%
  dplyr::summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = round(sum(total_species) / sum(total_species) * 100, 1)
  )

summary_table_final_region_regioncode_common_only <- bind_rows(summary_table, total_row) %>%
  arrange(desc(total_species))

# Step 6: Export to CSV
write.csv(summary_table_final_region_regioncode_common_only, "summary_species_zenodo_filtered.csv", row.names = FALSE)

# Step 7: Export to Word
ft <- flextable(summary_table_final_region_regioncode_common_only) %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

# Save as Word file
doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(value = ft)

print(doc, target = "summary_species_zenodo_filtered.docx")



combined_data_common_NEW_ES_PT_regioncode_common_only <- merge(final_region_regioncode_common_only_dedup, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# 4. Preview results
print(head(combined_data_common_NEW_ES_PT_regioncode_common_only, 5))


# 1. Count distinct Region values per TaxonName
region_counts <- zenodo_filtered %>%
  group_by(TaxonName) %>%
  summarise(region_count = n_distinct(Region), .groups = "drop")

# 2. Join counts back into the main data
zenodo_with_region_counts <- zenodo_filtered %>%
  left_join(region_counts, by = "TaxonName")

# 3. Split into repeated-region and single-region subsets
zenodo_repeated_regions <- zenodo_with_region_counts %>%
  filter(region_count > 1)

zenodo_single_region <- zenodo_with_region_counts %>%
  filter(region_count == 1)

# 4. Drop the helper column if desired
zenodo_repeated_regions <- zenodo_repeated_regions %>% select(-region_count)
zenodo_single_region <- zenodo_single_region %>% select(-region_count)

# 5. Preview
cat("?? TaxonNames in multiple regions:\n")
print(unique(zenodo_repeated_regions$TaxonName))

cat("\n? TaxonNames in a single region:\n")
print(unique(zenodo_single_region$TaxonName))



library(dplyr)
library(tidyr)
library(gt)
library(flextable)
library(officer)

# Step 0: Clean list of searched species (you already created this earlier)
# species_names_clean <- gsub("_", " ", names(all_lists_common_NEW_ES_PT_regioncode_common_only))

# Step 1: Add a temporary clean name column to zenodo_filtered for matching
zenodo_filtered <- zenodo_filtered %>%
  mutate(CleanName = gsub("_", " ", TaxonName))

# Step 2: Filter to only searched species using cleaned names
searched_zenodo <- zenodo_filtered %>%
  filter(CleanName %in% species_names_clean)

# Step 3: Combine found species (videos) with full metadata
combined_data_common_NEW_ES_PT_regioncode_common_only <- merge(final_region_regioncode_common_only_dedup, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# Step 4: Remove "Mammals" group (1 case only in found)
combined_data_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only %>% filter(LifeForm != "Mammals")
searched_zenodo <- searched_zenodo %>% filter(LifeForm != "Mammals")
zenodo_filtered <- zenodo_filtered %>% filter(LifeForm != "Mammals")

# ? Step 5: Compute total species per LifeForm from the full Zenodo dataset
total_species_summary <- zenodo_filtered %>%
  group_by(LifeForm) %>%
  summarise(total_species = n_distinct(TaxonName), .groups = "drop")

# Step 6: Compute searched species per LifeForm (subset of total)
searched_summary <- searched_zenodo %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(searched = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = searched, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_searched") %>%
  mutate(searched_species = rowSums(across(ends_with("_searched"))),
         pct_searched = round((searched_species / sum(searched_species)) * 100, 1))

# Step 7: Compute found species per LifeForm from combined dataset
found_summary <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(found = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = found, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_found") %>%
  mutate(species_found = rowSums(across(ends_with("_found"))),
         pct_found = round((species_found / sum(species_found)) * 100, 1))

# Step 8: Join summaries
final_table <- searched_summary %>%
  full_join(found_summary, by = "LifeForm") %>%
  full_join(total_species_summary, by = "LifeForm") %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(
    Alien = paste0(alien_found, "/", alien_searched),
    Established = paste0(established_found, "/", established_searched),
    Uncertain = paste0(uncertain_found, "/", uncertain_searched),
    Casual = paste0(casual_found, "/", casual_searched),
    `% Found / Searched` = paste0(pct_found, "/", pct_searched),
    `% Found of Searched` = paste0(round((species_found / searched_species) * 100, 1), "%")
  ) %>%
  dplyr::select(
    `Taxonomic Group` = LifeForm,
    `Total Species` = total_species,
    `Searched Species` = searched_species,
    `Species Found` = species_found,
    `% Found of Searched`,
    `% Found / Searched`,
    Alien, Established, Uncertain, Casual
  )

# Step 9: Add total row
total_row <- final_table %>%
  summarise(
    `Taxonomic Group` = "Total",
    `Total Species` = sum(`Total Species`),
    `Searched Species` = sum(`Searched Species`),
    `Species Found` = sum(`Species Found`),
    `% Found of Searched` = paste0(round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "%"),
    `% Found / Searched` = paste0(
      round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "/100"
    ),
    Alien = paste0(sum(as.integer(sub("/.*", "", Alien))), "/", sum(as.integer(sub(".*/", "", Alien)))),
    Established = paste0(sum(as.integer(sub("/.*", "", Established))), "/", sum(as.integer(sub(".*/", "", Established)))),
    Uncertain = paste0(sum(as.integer(sub("/.*", "", Uncertain))), "/", sum(as.integer(sub(".*/", "", Uncertain)))),
    Casual = paste0(sum(as.integer(sub("/.*", "", Casual))), "/", sum(as.integer(sub(".*/", "", Casual))))
  )

# Step 10: Bind total row to final table
final_table <- bind_rows(final_table, total_row)

# Step 11: Export to Word
ft <- flextable(final_table) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ `Taxonomic Group` == "Total", part = "body")

doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group (Found vs Searched)", style = "heading 1") %>%
  body_add_flextable(ft)

print(doc, target = "summary_species_combined_found_vs_searched.docx")

# Step 12: Export to CSV
write.csv(final_table, "summary_species_combined_found_vs_searched.csv", row.names = FALSE)



# 1. Find which TaxonName values are common
common_taxa <- intersect(
  unique(zenodo_single_region$TaxonName),
  unique(final_region_regioncode_common_only_dedup$TaxonName)
)

# 2. Subset the video dataset for these common TaxonNames
#videos_single_region <- final_region_regioncode_common_only_dedup %>%
#  filter(TaxonName %in% common_taxa)

# 3. Merge matched video data with zenodo_single_region
#combined_single_region <- videos_single_region %>%
#    left_join(zenodo_single_region, by = "TaxonName")

# 4. Optional: Remove unmatched rows after merge (those where LifeForm or Region is still NA)
#combined_single_region_clean <- combined_single_region %>%
#  filter(!is.na(LifeForm))

# 5. Now get the remaining (unmatched) videos for later merge with repeated-region species
#videos_remaining <- final_region_regioncode_common_only_dedup %>%
#  filter(!(TaxonName %in% common_taxa))

# 6. Preview results
#cat("? Combined single-region species dataset:\n")
#print(head(combined_single_region, 3))

#cat("\n?? Remaining videos to combine with repeated-region species:\n")
#print(head(videos_remaining, 3))


############################################################################ FILTERING OUT UNRELATED YT CHANNELS ############################################################################################

channels_to_remove <- c("Andrea Espadas", "Guías Pal Esp", "Daniel Mendes", "Quadros Brasi", "AVIRUKÁ", "LA VIEJOTECA DE FERCHO", "IlloJuan")

combined_data_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  filter(!(channelTitle %in% channels_to_remove))

# Optional: Preview removed rows if needed
removed_rows <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  filter(channelTitle %in% channels_to_remove)

cat("?? Rows removed:\n")
print(unique(removed_rows$channelTitle))

cat("\n? Final dataset dimensions:\n")
print(dim(combined_data_common_NEW_ES_PT_regioncode_common_only))


# Ensure your dataset is a data.table
setDT(combined_data_common_NEW_ES_PT_regioncode_common_only)

# Count number of rows (videos) per TaxonName
species_counts_combined_data_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only[, .N, by = TaxonName][order(-N)]

# View top species by video count
print(head(species_counts_combined_data_common_NEW_ES_PT_regioncode_common_only,30))

     TaxonName     N
                         <char> <int>
 1:         Psittacus_erithacus   534
 2:              Vespa_velutina   534
 3:    Geranoaetus_melanoleucus   322
 4:    Haliaeetus_leucocephalus   299
 5:             Anser_cygnoides   286
 6:          Lonchura_oryzivora   272
 7:       Spodoptera_frugiperda   268
 8:      Platycerium_bifurcatum   236
 9:              Bemisia_tabaci   227
10:               Aedes_aegypti   212
11:      Cherax_quadricarinatus   209
12:            Leuciscus_aspius   163
13:          Ceratitis_capitata   159
14:        Haemorhous_mexicanus   143
15:      Varanus_exanthematicus   141
16:        Cygnus_melancoryphus   134
17:     Reticulitermes_flavipes   130
18:          Synoicus_chinensis   127
19:       Rugulopteryx_okamurae   118
20: Paratrechina_jaegerskioeldi   115
21:   Tobamovirus_fructirugosum   108
22:      Procambarus_virginalis   107
23:   Scyphophorus_acupunctatus   107
24:              Platalea_ajaja    90
25:      Psephotus_haematonotus    86
26:           Halyomorpha_halys    85
27:           Branta_canadensis    61
28:            Vespa_orientalis    56
29:           Perca_fluviatilis    55
30:        Phthorimaea_absoluta    55
                      TaxonName     N


########################################################################### FILTERING FOR THE IBERIAN PENINSULA  ############################################################################################

# Required libraries
library(dplyr)
library(stringr)
library(textcat)
library(readr)

# STEP 1: Filter by language: Keep only Spanish or Portuguese
filter_languages <- function(data) {
  data %>%
    mutate(
      title_language = textcat(title),
      description_language = textcat(description)
    ) %>%
    filter(
      title_language %in% c("spanish", "portuguese") |
      description_language %in% c("spanish", "portuguese")
    ) %>%
    select(-title_language, -description_language)
}

# STEP 2: Get GeoNames place names for Spain and Portugal
get_iberian_locations <- function() {
  download_and_read <- function(country_code, col_localidad) {
    temp <- tempfile()
    download.file(paste0("http://download.geonames.org/export/zip/", country_code, ".zip"), temp)
    con <- unz(temp, paste0(country_code, ".txt"))
    data <- read.delim(con, header = FALSE, encoding = "UTF-8")
    unlink(temp)
    colnames(data)[col_localidad] <- "localidad"
    tolower(unique(data$localidad))
  }

  es_locations <- download_and_read("ES", 2)
  pt_locations <- download_and_read("PT", 2)

  unique(c(es_locations, pt_locations))
}

# STEP 3: Filter dataset to include only videos mentioning Iberian localities
filter_iberian_locations <- function(data, locations) {
  pattern <- paste0("\\b(", paste(locations, collapse = "|"), ")\\b")
  data %>%
    filter(
      str_detect(tolower(title), pattern) |
      str_detect(tolower(description), pattern)
    )
}

# ------------------ APPLY FILTERS TO YOUR DATA --------------------

# Replace this with your actual data
# combined_data_common_NEW_ES_PT_regioncode_common_only <- your_loaded_data

# Apply language filter
filtered_language_common_NEW_ES_PT_regioncode_common_only <- filter_languages(combined_data_common_NEW_ES_PT_regioncode_common_only)

# Get Iberian GeoNames locations
iberian_locations <- get_iberian_locations()

# Apply Iberian location filter
filtered_iberian_common_NEW_ES_PT_regioncode_common_only <- filter_iberian_locations(combined_data_common_NEW_ES_PT_regioncode_common_only, iberian_locations)
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only <- filter_iberian_locations(filtered_language_common_NEW_ES_PT_regioncode_common_only, iberian_locations)
filtered_excluded_only_iberian_common_NEW_ES_PT_regioncode_common_only <- filter_iberian_locations(filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only, iberian_locations)


# Summary
cat("Original dataset rows:", nrow(combined_data_common_NEW_ES_PT_regioncode_common_only), "\n")
cat("After language filter:", nrow(filtered_language_common_NEW_ES_PT_regioncode_common_only), "\n")
cat("After Iberian location and language filters:", nrow(filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only), "\n")

# View sample result
print(head(filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only, 5))



library(dplyr)
library(stringr)

# Define a list of non-Iberian Spanish/Portuguese-speaking countries to exclude
exclude_countries <- c(
  "mexico", "argentina", "chile", "colombia", "venezuela", "peru", "bolivia", "paraguay", "uruguay", "ecuador",
  "cuba", "dominican republic", "el salvador", "honduras", "guatemala", "panama", "nicaragua", "puerto rico",
  "brazil", "angola", "mozambique", "cape verde", "guinea-bissau", "sao tome and principe", "timor-leste"
)

# Create a regex pattern with word boundaries
exclude_pattern <- paste0("\\b(", paste0(exclude_countries, collapse = "|"), ")\\b")

# Filter out any rows from `filtered_language_common_NEW_ES_PT_regioncode_common_only` that mention those countries in title or description
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only <- filtered_language_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )

# Filter out any rows from `filtered_language_common_NEW_ES_PT_regioncode_common_only` that mention those countries in title or description
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only <- filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )

# Filter out any rows from `filtered_language_common_NEW_ES_PT_regioncode_common_only` that mention those countries in title or description
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only <- filtered_iberian_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )


# Optional: View a sample
print(head(filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only, 5))
print(head(filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only, 5))


#############################################################################################################################################################################################################
#############################################################################################################################################################################################################
###############################################3###### DATASET TESTS FROM OLD VERSIONS (JUST TO COMPARE THE FILTERING PROCESS AND OUTPUT) ###################################################################
#############################################################################################################################################################################################################

include_keywords <- c(
  # Spanish (Español)
  "mamíferos", "mamífero", "aves", "ave", "anfibios", "anfibio",
  "reptiles", "reptil", "peces", "pez", "invertebrados", "invertebrado",
  "moluscos", "molusco", "bivalvos", "bivalvo", "cefalópodos", "cefalópodo",
  "artrópodos", "artrópodo", "crustáceos", "crustáceo", "medusas", "medusa",
  "cnidarios", "cnidario", "equinodermos", "equinodermo", "insectos", "insecto",
  "arácnidos", "arácnido", "miriápodos", "miriápodo",

  # Portuguese (Portugal)
  "anfíbios", "anfíbio", "répteis", "réptil", "peixes", "peixe",
  "bivalves", "bivalve", "cefalópodes", "cefalópode", "artrópodes", "artrópode",
  "águas-vivas", "água-viva", "cnidários", "cnidário", "insetos", "inseto",
  "aracnídeos", "aracnídeo", "miriápodes", "miriápode",

  # Catalan (Català)
  "mamífers", "mamífer", "aus", "ocell", "amfibis", "amfibi",
  "rèptils", "rèptil", "peixos", "peix", "invertebrats", "invertebrat",
  "mol·luscs", "mol·lusc", "cefalòpodes", "cefalòpode", "artròpodes", "artròpode",
  "crustacis", "crustaci", "meduses", "cnidaris", "cnidari", "equinoderms",
  "equinoderm", "insectes", "insecte", "aràcnids", "aràcnid", "miriàpodes", "miriàpode",

  # Galician (Galego)
  "réptiles", "peixes", "anfibios", "anfibio",

  # Basque (Euskara)
  "ugaztunak", "ugaztuna", "hegaztiak", "hegaztia", "anfibioak", "anfibioa",
  "narrastiak", "narrastia", "arrainak", "arraina", "ornogabeak", "ornogabea",
  "moluskuak", "moluskua", "bibalboak", "bibalboa", "zefalopodoak", "zefalopodoa",
  "artropodoak", "artropodoa", "krustazeoak", "krustazea", "medusak", "knidarioak",
  "knidarioa", "ekinodermoak", "ekinodermoa", "intsektuak", "intsektua", "araknidoak",
  "araknidoa", "miriapodoak", "miriapodoa",

  # Asturian (Asturianu)
  "mamíferu", "anfibiu", "invertebraos", "invertebrau", "moluscu", "bivalvu",
  "cefalópodu", "artrópodu", "crustáceu", "cnidariu", "equinodermu", "insectu",
  "arácnidu", "miriápodu",

  # Spanish
  "especies invasoras", "especie invasora", "especie", "Especie", "insecto",
  "cotorra", "Insecto", "Cotorra", "amenaza", "ave", "aves", "tortuga",
  "tortugas", "serpiente", "serpientes", "lagartija", "lagartijas", "lagarto",
  "lagartos", "pez", "peces", "anfibio", "anfibios", "naturaleza", "peligrosa",
  "peligrosas", "invasora", "invasoras", "rana", "ranas", "pájaro", "pájaros",
  "reptil", "reptiles", "especie exótica invasora", "especies exóticas invasoras",
  "especie exótica", "especies exóticas", "EEI", "EEIs", "Especies Exóticas Invasoras",
  "Especies exóticas invasoras", "Especie exótica", "Especies exóticas", "Especie Exótica Invasora",
  "Especie exótica invasora", "invasiones biológicas", "invasión biológica", "Invasiones biológicas",
  "Invasión biológica", "especie introducida", "Especie introducida", "especies introducidas",
  "Especies introducidas", "pérdida de biodiversidad", "degradación ambiental", "impacto ecológico",
  "cambio de hábitat", "dispersión", "competencia", "hibridación", "extinción",
  "sobrepoblación", "equilibrio ecológico", "ecosistema", "sostenibilidad",

  # Portuguese (Portugal)
  "espécies invasoras", "espécie invasora", "espécie", "inseto", "papagaio",
  "ameaça", "ave", "aves", "tartaruga", "tartarugas", "serpente", "serpentes",
  "lagartixa", "lagartixas", "lagarto", "lagartos", "peixe", "peixes",
  "anfíbio", "anfíbios", "natureza", "perigosa", "perigosas", "invasora", "invasoras",
  "rã", "rãs", "pássaro", "pássaros", "réptil", "répteis", "espécie exótica invasora",
  "espécies exóticas invasoras", "espécie exótica", "espécies exóticas", "EEI", "EEIs",
  "Espécies Exóticas Invasoras", "Espécies exóticas invasoras", "Espécie exótica",
  "Espécies exóticas", "Espécie Exótica Invasora", "Espécie exótica invasora",
  "invasões biológicas", "invasão biológica", "espécie introduzida", "espécies introduzidas",
  "perda de biodiversidade", "degradação ambiental", "impacto ecológico", "mudança de habitat",
  "dispersão", "competição", "hibridação", "extinção", "superpopulação", "equilíbrio ecológico",
  "ecossistema", "sustentabilidade",

  # Catalan (Català)
  "espècies invasores", "espècie invasora", "espècie", "insecte", "lloro",
  "amenaça", "ocell", "ocells", "tortuga", "tortugues", "serp", "serps",
  "llangardaix", "llangardaixos", "granota", "granotes", "peix", "peixos",
  "amfibi", "amfibis", "natura", "perillosa", "perilloses", "invasora", "invasores",
  "rèptil", "rèptils", "espècie exòtica invasora", "espècies exòtiques invasores",
  "espècie exòtica", "espècies exòtiques", "EEI", "EEIs", "Espècies Exòtiques Invasores",
  "Espècies exòtiques invasores", "Espècie exòtica", "Espècies exòtiques",
  "Espècie Exòtica Invasora", "Espècie exòtica invasora", "invasions biològiques",
  "invasió biològica", "espècie introduïda", "espècies introduïdes", "pèrdua de biodiversitat",
  "degradació ambiental", "impacte ecològic", "canvi d'hàbitat", "dispersió",
  "competència", "hibridació", "extinció", "superpoblació", "equilibri ecològic",
  "ecosistema", "sostenibilitat",

  # Galician (Galego)
  "especies invasoras", "especie invasora", "especie", "insecto", "papagaio",
  "ameaza", "ave", "aves", "tartaruga", "tartarugas", "serpe", "serpes",
  "lagarto", "lagartos", "ra", "ras", "peixe", "peixes", "anfibio", "anfibios",
  "natureza", "perigosa", "perigosas", "invasora", "invasoras", "paxaro", "paxaros",
  "réptil", "réptiles", "especie exótica invasora", "especies exóticas invasoras",
  "especie exótica", "especies exóticas", "EEI", "EEIs", "Especies Exóticas Invasoras",
  "Especies exóticas invasoras", "Especie exótica", "Especies exóticas",
  "Especie Exótica Invasora", "Especie exótica invasora", "invasións biolóxicas",
  "invasión biolóxica", "especie introducida", "especies introducidas",
  "perda de biodiversidade", "degradación ambiental", "impacto ecolóxico",
  "cambio de hábitat", "dispersión", "competencia", "hibridación", "extinción",
  "superpoboación", "equilibrio ecolóxico", "ecosistema", "sustentabilidade",

  # Basque (Euskara)
  "espezie inbaditzaileak", "espezie inbaditzailea", "espezie", "intsektua",
  "loroa", "mehatxua", "txoria", "txoriak", "dortoka", "dortokak", "sugea",
  "sugeak", "muskerra", "muskerrak", "arraina", "arrainak", "anfibioa",
  "anfibioak", "ingurumena", "arriskutsua", "arriskutsuak", "inbaditzailea",
  "inbaditzaileak", "narrastia", "narrastiak", "espezie exotiko inbaditzailea",
  "espezie exotiko inbaditzaileak", "EEI", "EEIs", "espezie sartutakoa",
  "espezie sartutakoak", "inbasio biologikoak", "inbasio biologikoa",
  "ingurumenaren degradazioa", "habitataren aldaketa", "banaketa", "konpetentzia",
  "hibridazioa", "desagertzea", "gehiegizko populazioa", "ekosistema", "iraunkortasuna",

  # Threats and impact of IAS
  "amenaza", "impacto ecológico", "pérdida de biodiversidad", "desequilibrio ecológico",
  "degradación ambiental", "invasiones biológicas", "invasión biológica", "invasora", "invasoras",
  "especie exótica invasora", "especies exóticas invasoras", "competencia ecológica",
  "extinción de especies", "cambio de hábitat", "sobrepoblación", "ecosistema",
  "sostenibilidad", "efecto en la biodiversidad", "dispersión",

  # IAS related taxonomy
  "rana", "ranas", "pájaro", "pájaros", "reptil", "reptiles",
  "tortuga", "tortugas", "serpiente", "serpientes", "lagartija", "lagartijas",
  "lagarto", "lagartos", "pez", "peces", "anfibio", "anfibios",

  # Human-related introduction and consequences
  "especie introducida", "especies introducidas", "invasión ecológica",
  "efecto en la fauna", "impacto ambiental", "contagio de enfermedades",
  "plaga ecológica", "especies invasoras en ríos", "fauna invasora",

  # Portuguese (Portugal)
  "espécies invasoras", "espécie invasora", "espécie", "inseto", "pássaro",
  "papagaio", "sapo", "tartaruga", "cobra", "lagarto", "peixe",
  "ameaça", "impacto ecológico", "perda de biodiversidade", "desequilíbrio ecológico",
  "degradação ambiental", "invasões biológicas", "invasão biológica", "competição ecológica",
  "extinção de espécies", "mudança de habitat", "superpopulação", "ecossistema",
  "sustentabilidade", "efeito na biodiversidade", "dispersão",

  # IAS related taxonomy (Portuguese)
  "rã", "rãs", "réptil", "répteis", "tartarugas", "serpente", "serpentes",
  "lagartixa", "lagartixas", "lagartos", "anfíbio", "anfíbios",
  "espécie exótica invasora", "espécies exóticas invasoras",

  # Human-related introduction and consequences (Portuguese)
  "espécie introduzida", "espécies introduzidas", "invasão ecológica",
  "efeito na fauna", "impacto ambiental", "transmissão de doenças",
  "praga ecológica", "espécies invasoras em rios", "fauna invasora",

  # Catalan (Català)
  "espècies invasores", "espècie invasora", "espècie", "insecte", "ocell",
  "lloro", "granota", "tortuga", "serp", "llangardaix", "peix",
  "amenaça", "impacte ecològic", "pèrdua de biodiversitat", "desequilibri ecològic",
  "degradació ambiental", "invasions biològiques", "invasió biològica",
  "competència ecològica", "extinció d'espècies", "canvi d'hàbitat",
  "superpoblació", "ecosistema", "sostenibilitat", "efecte en la biodiversitat",
  "dispersió",

  # IAS related taxonomy (Catalan)
  "granota", "granotes", "ocell", "ocells", "rèptil", "rèptils", "tortuga", "tortugues",
  "serp", "serps", "llangardaix", "llangardaixos", "peix", "peixos", "amfibi", "amfibis",
  "espècie exòtica invasora", "espècies exòtiques invasores",

  # Human-related introduction and consequences (Catalan)
  "espècie introduïda", "espècies introduïdes", "invasió ecològica",
  "efecte en la fauna", "impacte ambiental", "contagi de malalties",
  "plaga ecològica", "espècies invasores en rius", "fauna invasora",

  # Galician (Galego)
  "especies invasoras", "especie invasora", "especie", "insecto",
  "paxaro", "papagaio", "ra", "tartaruga", "cobreg", "lagarto", "peixe",
  "ameaza", "impacto ecolóxico", "perda de biodiversidade", "desequilibrio ecolóxico",
  "degradación ambiental", "invasións biolóxicas", "invasión biolóxica",
  "competencia ecolóxica", "extinción de especies", "cambio de hábitat",
  "superpoboación", "ecosistema", "sustentabilidade", "efecto na biodiversidade",
  "dispersión",

  # IAS related taxonomy (Galician)
  "ra", "ras", "paxaro", "paxaros", "réptil", "réptiles", "tartaruga",
  "tartarugas", "serpe", "serpes", "lagarto", "lagartos", "anfibio", "anfibios",
  "especie exótica invasora", "especies exóticas invasoras",

  # Human-related introduction and consequences (Galician)
  "especie introducida", "especies introducidas", "invasión ecolóxica",
  "efecto na fauna", "impacto ambiental", "contaxio de enfermidades",
  "praga ecolóxica", "especies invasoras en ríos", "fauna invasora",

  # Basque (Euskara)
  "espezie inbaditzaileak", "espezie inbaditzailea", "espezie",
  "intsektua", "txoria", "loroa", "igela", "dortoka", "sugea", "muskerra", "arraina",
  "mehatxua", "ingurumen-eragina", "biodibertsitate galera", "ekosistemaren desoreka",
  "ingurumenaren degradazioa", "inbasio biologikoak", "inbasio biologikoa",
  "ekosistema", "iraunkortasuna", "banaketa",

  # IAS related taxonomy (Basque)
  "igela", "igelak", "txoria", "txoriak", "narrastia", "narrastiak",
  "dortoka", "dortokak", "sugea", "sugeak", "muskerra", "muskerrak",
  "arraina", "arrainak", "anfibioa", "anfibioak",
  "espezie exotiko inbaditzailea", "espezie exotiko inbaditzaileak",

  # Human-related introduction and consequences (Basque)
  "sartutako espeziea", "sartutako espezieak", "inbasio ekologikoa",
  "ingurumen-eragina", "gaixotasunen kutsapena", "izurrite ekologikoa",
  "ibaietako espezie inbaditzaileak", "fauna inbaditzailea"
)


exclude_keywords <- c(
  # English & Spanish
  "soccer", "football", "gaming", "entertainment", "movie", "movies",
  "game", "games", "videogame", "basketball", "videogames", "music",
  "concert", "teams", "team", "tournament", "tournaments", "series",
  "videojuego", "juego", "videojuegos", "juegos", "partido", "partidos",
  "fútbol", "baloncesto", "música", "gamer", "gamers", "jugador", "jugadores",
  "sports", "película", "películas", "consola", "consolas", "canción",
  "canciones", "bailar", "baile", "bailes", "moda", "ropa", "celebridad",
  "humor", "comedia", "entretenimiento", "noticias falsas", "clickbait",
  "viral", "memes", "tecnología", "ciencia ficción", "inteligencia artificial",

  "São Paulo", "Elden Ring", "Pica-Pau", "PICA-PAU", "Red Dead Redemption",
  "Brasileiro", "Cartoons", "Depilação", "Consolador", "Peppa Pig", "Gameplay",
  "Pokemon", "Lets Play", "Dragon Ball Z", "Pocoyo", "Chile", "Brasil",
  "Assassin's Creed", "Argentina", "Assassins Creed", "PlayStation", "Playstation",
  "Xbox",

  # Portuguese (Portugal)
  "futebol", "basquetebol", "jogos", "gaming", "jogo", "videojogo",
  "videojogos", "música", "concerto", "equipas", "equipa", "torneio",
  "torneios", "série", "séries", "filme", "filmes", "desporto", "jogador",
  "jogadores", "consola", "consolas", "canção", "canções", "dança", "dançar",
  "danças", "moda", "roupa", "celebridade", "famoso", "famosos", "humor",
  "comédia", "entretenimento", "notícias falsas", "clickbait", "viral",
  "memes", "tecnologia", "ficção científica", "inteligência artificial",

  # Catalan (Català)
  "futbol", "bàsquet", "jocs", "joc", "videojoc", "videojocs", "música",
  "concert", "equips", "equip", "torneig", "tornejos", "sèrie", "sèries",
  "pel·lícula", "pel·lícules", "esports", "jugador", "jugadors", "consola",
  "consoles", "cançó", "cançons", "ballar", "ball", "balls", "moda", "roba",
  "celebritat", "humor", "comèdia", "entreteniment", "notícies falses",
  "clickbait", "viral", "mems", "tecnologia", "ciència-ficció",
  "intel·ligència artificial",

  # Galician (Galego)
  "fútbol", "baloncesto", "xogos", "xogo", "videoxogo", "videoxogos", "música",
  "concerto", "equipos", "equipo", "torneo", "torneos", "serie", "series",
  "película", "películas", "deporte", "xogador", "xogadores", "consola",
  "consolas", "canción", "cancións", "bailar", "baile", "bailes", "moda",
  "roupa", "celebridade", "humor", "comedia", "entretenemento",
  "novas falsas", "clickbait", "viral", "memes", "tecnoloxía",
  "ciencia ficción", "intelixencia artificial",

  # Basque (Euskara)
  "futbola", "saskibaloia", "jokoak", "jokoa", "bideojokoa", "bideojokoak",
  "musika", "kontzertua", "taldeak", "taldea", "txapelketa", "txapelketak",
  "saioa", "saioak", "filma", "filmak", "kirola", "jokalaria", "jokalariak",
  "kontsola", "kontsolak", "kanta", "kantak", "dantza", "moda", "arropa",
  "ospetsua", "umorea", "komedia", "aisialdia", "albiste faltsuak",
  "clickbait", "birala", "memak", "teknologia", "fikzio zientifikoa",
  "adimen artifiziala",

  # Asturian (Asturianu)
  "fútbol", "baloncestu", "xuegos", "xuegu", "videoxuegu", "videoxuegos",
  "música", "conciertu", "equipos", "equipu", "torneu", "torneos", "serie",
  "series", "película", "películes", "deporte", "xugador", "xugadores",
  "consola", "consoles", "canción", "canciones", "bailar", "baile", "bailes",
  "moda", "ropa", "celebritá", "humor", "comedia", "entretenimientu",
  "noticies falses", "clickbait", "viral", "memes", "tecnoloxía",
  "ciencia ficción", "intelixencia artificial"
)



library(dplyr)
library(stringr)

# Combine description text to lower case (if not already)
combined_data_common_NEW_ES_PT_regioncode_common_only_lower <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  mutate(full_description_lower = tolower(description))

# Inclusion filter (any include keyword matches)
filtered_included_only_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only_lower %>%
  filter(str_detect(full_description_lower, paste0("\\b(", paste(include_keywords, collapse = "|"), ")\\b")))

# Exclusion filter (remove rows with any exclude keyword)
filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only_lower %>%
  filter(!str_detect(full_description_lower, paste0("\\b(", paste(exclude_keywords, collapse = "|"), ")\\b")))

# Combined filter (inclusion AND NOT exclusion)
filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only <- combined_data_common_NEW_ES_PT_regioncode_common_only_lower %>%
  filter(
    str_detect(full_description_lower, paste0("\\b(", paste(include_keywords, collapse = "|"), ")\\b")) &
    !str_detect(full_description_lower, paste0("\\b(", paste(exclude_keywords, collapse = "|"), ")\\b"))
  )


# Optional: check sizes
cat("?? Combined (include and not exclude):", nrow(filtered_included_only_common_NEW_ES_PT_regioncode_common_only), "rows\n")
?? Combined (include and not exclude): 670 rows

cat("? Excluded only (removed unwanted):", nrow(filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only), "rows\n")
Excluded only (removed unwanted): 6309 rows

cat("?? Combined (include and not exclude):", nrow(filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only), "rows\n")
?? Combined (include and not exclude): 652 rows


#############################################################################################################################################################################################################

library(dplyr)
library(stringr)
library(readr)

# Step 1: Load and Clean Spanish & Portuguese Locations from Geonames
load_geonames <- function(country_code, col_indices) {
  temp <- tempfile()
  url <- paste0("http://download.geonames.org/export/zip/", country_code, ".zip")
  download.file(url, temp)
  con <- unz(temp, paste0(country_code, ".txt"))
  df <- read.delim(con, header = FALSE, encoding = "UTF-8")
  unlink(temp)

  colnames(df)[col_indices] <- c("comunidad", "ciudad", "localidad")
  df <- df[col_indices]
  df <- unique(tolower(unlist(df)))  # Flatten to a unique vector
  df <- df[df != ""]  # Remove empty values
  return(df)
}

localities_ES <- load_geonames("ES", c(4, 6, 8))
localities_PT <- load_geonames("PT", c(3, 4, 8))

# Combine and clean location lists
localities_all <- unique(c(localities_ES, localities_PT))
localities_all <- localities_all[!is.na(localities_all)]

# Step 2: Keep videos mentioning Spain/Portugal locations OR missing location info
filter_by_location <- function(data, locations) {
  data %>% filter(
    str_detect(tolower(title), paste(locations, collapse = "|") ) |
    str_detect(tolower(description), paste(locations, collapse = "|")) |
    is.na(title) | is.na(description)
  )
}
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2 <- filter_by_location(combined_data_common_NEW_ES_PT_regioncode_common_only, localities_all)
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2 <- filter_by_location(filtered_language_common_NEW_ES_PT_regioncode_common_only, localities_all)
filtered_excluded_only_iberian_common_NEW_ES_PT_regioncode_common_only_2 <- filter_by_location(filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only, localities_all)

# Step 3: Exclude non-Iberian Spanish/Portuguese-speaking countries
exclude_countries <- c("mexico", "argentina", "chile", "colombia", "venezuela", "peru", "brazil",
                       "ecuador", "uruguay", "paraguay", "bolivia", "guatemala", "honduras",
                       "el salvador", "dominican republic", "panama", "nicaragua", "cuba",
                       "angola", "mozambique", "cape verde", "guinea-bissau", "sao tome and principe", "equatorial guinea")

exclude_regex <- paste0("\\b(", paste(exclude_countries, collapse = "|"), ")\\b")



filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2 <- filtered_language_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )

filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2 <- filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2 %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )

filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2 <- filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2 %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )


# Step 2: Filter by Keywords
filter_by_keywords <- function(data, include_keywords, exclude_keywords) {
  data %>%
    filter(
      str_detect(title, paste(include_keywords, collapse = "|")) |
        str_detect(description, paste(include_keywords, collapse = "|"))
    ) %>%
    filter(
      !str_detect(title, paste(exclude_keywords, collapse = "|")) &
        !str_detect(description, paste(exclude_keywords, collapse = "|"))
    )
}


library(dplyr)
library(stringr)
library(textcat)

# ---- Step 1: Prepare Localities ----
prepare_localities <- function() {
  # Download and process Spanish localities
  temp_es <- tempfile()
  download.file("http://download.geonames.org/export/zip/ES.zip", temp_es)
  con_es <- unz(temp_es, "ES.txt")
  localities_ES <- read.delim(con_es, header = FALSE)
  unlink(temp_es)
  colnames(localities_ES)[c(4, 6, 8)] <- c("comunidad", "ciudad", "localidad")
  localities_ES <- localities_ES[c(4, 6, 8)]
  localities_ES$localidad <- tolower(localities_ES$localidad)

  # Download and process Portuguese localities
  temp_pt <- tempfile()
  download.file("http://download.geonames.org/export/zip/PT.zip", temp_pt)
  con_pt <- unz(temp_pt, "PT.txt")
  localities_PT <- read.delim(con_pt, header = FALSE)
  unlink(temp_pt)
  colnames(localities_PT)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
  localities_PT <- localities_PT[c(3, 4, 8)]
  localities_PT$localidad <- tolower(localities_PT$localidad)

  # Combine both
  localities_NEW_ES_PT_regioncode_common_only_ALL3 <- full_join(localities_PT, localities_ES, by = c("comunidad", "ciudad", "localidad"))
  unique(tolower(localities_NEW_ES_PT_regioncode_common_only_ALL3$localidad))
}

# ---- Step 2: Filtering Functions ----

# Filter by keywords (include and optionally exclude)
filter_by_keywords <- function(data, include_keywords, exclude_keywords = NULL) {
  data_filtered <- data %>%
    filter(
      str_detect(tolower(title), paste(include_keywords, collapse = "|")) |
        str_detect(tolower(description), paste(include_keywords, collapse = "|"))
    )

  if (!is.null(exclude_keywords)) {
    data_filtered <- data_filtered %>%
      filter(
        !str_detect(tolower(title), paste(exclude_keywords, collapse = "|")) &
        !str_detect(tolower(description), paste(exclude_keywords, collapse = "|"))
      )
  }

  return(data_filtered)
}

# Filter by detected language
filter_by_language <- function(data, target_languages = c("spanish", "portuguese")) {
  data %>%
    mutate(detected_language = textcat::textcat(description)) %>%
    filter(detected_language %in% target_languages)
}

# Filter by location (title or description contains locality)
filter_by_location <- function(data, locations) {
  data %>%
    filter(
      str_detect(tolower(title), paste(locations, collapse = "|")) |
        str_detect(tolower(description), paste(locations, collapse = "|"))
    )
}

# ---- Step 3: Master Filtering Function ----
process_youtube_data <- function(data, include_keywords, exclude_keywords, locations) {
  data %>%
    filter_by_keywords(include_keywords, exclude_keywords) %>%
    filter_by_language(target_languages = c("spanish", "portuguese")) %>%
    filter_by_location(locations)
}

# ---- Step 4: Apply Filtering ----

# Prepare localities (only once)
localities_vector <- prepare_localities()

# Assume you already have these lists defined in your session
# include_keywords <- c("invasive", "species", ...)  # etc.
# exclude_keywords <- c("non-invasive", ...)         # optional

# Now apply the filters individually if needed
filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3 <- filter_by_keywords(
  combined_data_common_NEW_ES_PT_regioncode_common_only,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords
)

filtered_Iberian_common_NEW_ES_PT_regioncode_common_only_3 <- filter_by_location(
  combined_data_common_NEW_ES_PT_regioncode_common_only,
  locations = localities_vector
)

filtered_language_common_NEW_ES_PT_regioncode_common_only_3 <- filter_by_language(
  combined_data_common_NEW_ES_PT_regioncode_common_only,
  target_languages = c("spanish", "portuguese")
)

# Or apply all filters together
filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3 <- process_youtube_data(
  combined_data_common_NEW_ES_PT_regioncode_common_only,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)


# Prepare localities (if not already created)
localities_vector <- prepare_localities()

# Now call with all required arguments:
filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3 <- process_youtube_data(
  filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3 <- process_youtube_data(
  filtered_included_only_common_NEW_ES_PT_regioncode_common_only,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3 <- process_youtube_data(
  filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

# Step 1: Prepare exclusion localities (as previously done)
prepare_exclusion_localities_refined <- function() {
    countries <- c("MX", "AR", "CL", "CO", "VE", "BO", "PY", "UY", "PE", "EC", "BR", "DO", "CR", "GT", "HN", "SV", "NI", "CU", "PA")
    exclusion_localities <- list()

    for (country in countries) {
        cat("Processing country:", country, "\n")
        temp_file <- tempfile()
        download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

        tryCatch({
            download.file(download_url, temp_file)
            con <- unz(temp_file, paste0(country, ".txt"))
            country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
            unlink(temp_file)

            colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
            localities <- country_data[, c("localidad", "comunidad", "ciudad")]
            localities <- unique(tolower(unlist(localities)))
            exclusion_localities <- c(exclusion_localities, localities)
        }, error = function(e) {
            cat("Skipping country:", country, "due to missing or inaccessible file.\n")
        })
    }

    # Escape special characters and filter out overly generic terms
    exclusion_localities <- str_replace_all(exclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
    exclusion_localities <- exclusion_localities[!exclusion_localities %in% c("centro", "primavera", "del carmen")]

    unique(exclusion_localities)
}

# Prepare the exclusion localities
exclusion_localities <- prepare_exclusion_localities_refined()

# Step 2: Create regex pattern with stricter word boundaries
exclusion_pattern <- paste0("\\b(", paste(unique(exclusion_localities), collapse = "|"), ")\\b")

# Step 3: Apply the exclusion filter with the refined pattern
filter_by_exclusion_refined <- function(data, pattern) {
    data %>%
        filter(
            !str_detect(tolower(title), pattern) &
                !str_detect(tolower(description), pattern)
        )
}

# Step 4: Apply the filter to the dataset
filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4 <- filter_by_exclusion_refined(
    combined_data_common_NEW_ES_PT_regioncode_common_only, exclusion_pattern
)


library(dplyr)
library(stringr)

# Step 1: Prepare inclusion localities from Iberian regions
prepare_inclusion_localities_iberian <- function() {
  iberian_countries <- c("PT", "ES")  # Portugal and Spain include regions like Azores, Madeira, Canary
  inclusion_localities <- list()

  for (country in iberian_countries) {
    cat("Processing country:", country, "\n")
    temp_file <- tempfile()
    download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

    tryCatch({
      download.file(download_url, temp_file)
      con <- unz(temp_file, paste0(country, ".txt"))
      country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
      unlink(temp_file)

      colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
      localities <- country_data[, c("localidad", "comunidad", "ciudad")]
      localities <- unique(tolower(unlist(localities)))
      inclusion_localities <- c(inclusion_localities, localities)
    }, error = function(e) {
      cat("Skipping country:", country, "due to missing or inaccessible file.\n")
    })
  }

  # Clean up and return
  inclusion_localities <- str_replace_all(inclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
  unique(inclusion_localities)
}

# Prepare Iberian inclusion localities
inclusion_localities <- prepare_inclusion_localities_iberian()
inclusion_pattern <- paste0("\\b(", paste(unique(inclusion_localities), collapse = "|"), ")\\b")

# Step 2: Apply the Iberian inclusion filter only
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4 <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    str_detect(tolower(title), inclusion_pattern) |
    str_detect(tolower(description), inclusion_pattern)
  )


# Step 1: Prepare exclusion localities (non-Iberian countries)
prepare_exclusion_localities_refined <- function() {
  countries <- c("MX", "AR", "CL", "CO", "VE", "BO", "PY", "UY", "PE", "EC", "BR", "DO", "CR", "GT", "HN", "SV", "NI", "CU", "PA")
  exclusion_localities <- list()

  for (country in countries) {
    cat("Processing country:", country, "\n")
    temp_file <- tempfile()
    download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

    tryCatch({
      download.file(download_url, temp_file)
      con <- unz(temp_file, paste0(country, ".txt"))
      country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
      unlink(temp_file)

      colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
      localities <- country_data[, c("localidad", "comunidad", "ciudad")]
      localities <- unique(tolower(unlist(localities)))
      exclusion_localities <- c(exclusion_localities, localities)
    }, error = function(e) {
      cat("Skipping country:", country, "due to missing or inaccessible file.\n")
    })
  }

  exclusion_localities <- str_replace_all(exclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
  exclusion_localities <- exclusion_localities[!exclusion_localities %in% c("centro", "primavera", "del carmen")]
  unique(exclusion_localities)
}

# Reuse Iberian locality inclusion from script #1
inclusion_localities <- prepare_inclusion_localities_iberian()
exclusion_localities <- prepare_exclusion_localities_refined()

# Create regex patterns
inclusion_pattern <- paste0("\\b(", paste(unique(inclusion_localities), collapse = "|"), ")\\b")
exclusion_pattern <- paste0("\\b(", paste(unique(exclusion_localities), collapse = "|"), ")\\b")

# Step 2: Apply both filters
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4 <- combined_data_common_NEW_ES_PT_regioncode_common_only %>%
  filter(
    !str_detect(tolower(title), exclusion_pattern) &
    !str_detect(tolower(description), exclusion_pattern) &
    (
      str_detect(tolower(title), inclusion_pattern) |
      str_detect(tolower(description), inclusion_pattern)
    )
  )


#################################################################################### DATASETS SUMMARY RESULTS ###############################################################################################

# Load necessary library
library(dplyr)

# List of datasets you have loaded in your environment
dataset_names <- c(
  "filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4",
  "filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4",
  "filtered_iberian_common_NEW_ES_PT_regioncode_common_only",
  "filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only",
  "filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only",
  "filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_language_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only",
  "filtered_included_only_common_NEW_ES_PT_regioncode_common_only",
  "filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only",
  "filtered_language_common_NEW_ES_PT_regioncode_common_only",
  "filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2",
  "filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only",
  "filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2",
  "filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2",
  "filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_3",
  "filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2",
  "filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2",
  "filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4"
)

# Descriptions (in the same order)
dataset_descriptions <- c(
  "After Iberian (method 4), non_iberian_counties excluded (method 4)",
  "After non_iberian_counties excluded (method 4)",
  "After Iberian filter (method 1)",
  "After Iberian filter (method 1), non_iberian_counties excluded (method 1)",
  "After language and Iberian (method 1) location filters",
  "After keywords filter (include and not exclude), language (method 3) and Iberian (method 3) filters",
  "After keywords filter (included only), language (method 3) and Iberian (method 3) filters",
  "After keywords filter (exclude only), language (method 3) and Iberian (method 3) filters",
  "After keywords, language (method 3) and Iberian (method 3) location filters",
  "After keywords filter (method 3)",
  "After language filter (method 3)",
  "After keywords filter (include and not exclude)",
  "After keywords filter (include only)",
  "After keywords filter (exclude only)",
  "After language filter (method 1)",
  "After language (method 1) and Iberian (method 2) location filters",
  "After language (method 3) and Iberian (method 3) location filters",
  "After language filter, non_iberian_counties excluded (method 1)",
  "After language filter, non_iberian_counties excluded (method 2)",
  "After language and Iberian (method 2) location filters, non_iberian_counties excluded (method 2)",
  "After language (method 3) and Iberian (method 3) location filters, non_iberian_counties excluded (method 3)",
  "After Iberian filter (method 2)",
  "After Iberian filter (method 2), non_iberian_counties excluded (method 2)",
  "After Iberian filter (method 4)"
)

# Create a data frame by looping through dataset names and calculating nrow
dataset_info <- data.frame(
  Dataset = dataset_names,
  Description = dataset_descriptions,
  Row_Count = sapply(dataset_names, function(x) {
    if (exists(x)) {
      nrow(get(x))
    } else {
      NA  # In case any dataset is missing
    }
  }),
  stringsAsFactors = FALSE
)

# Sort the resulting table by Row_Count
dataset_info_sorted <- dataset_info %>%
  arrange(Row_Count)

# View
print(dataset_info_sorted)

                                                                                                                                              Dataset
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                               filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4
filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                                               filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only                                                                           filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                                                   filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only
filtered_iberian_common_NEW_ES_PT_regioncode_common_only                                                                                             filtered_iberian_common_NEW_ES_PT_regioncode_common_only
filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3 filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3
filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3                         filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3
filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only                                                         filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only
filtered_included_only_common_NEW_ES_PT_regioncode_common_only                                                                                 filtered_included_only_common_NEW_ES_PT_regioncode_common_only
filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3                         filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3
filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                                     filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3
filtered_language_common_NEW_ES_PT_regioncode_common_only_3                                                                                       filtered_language_common_NEW_ES_PT_regioncode_common_only_3
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                             filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2
filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3                                                                                       filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2                                                                       filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                                                 filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                                             filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2
filtered_language_common_NEW_ES_PT_regioncode_common_only                                                                                           filtered_language_common_NEW_ES_PT_regioncode_common_only
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                                               filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2                                                                                         filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2
filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only                                                                                 filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4                                                                                         filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                                                       filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_3
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_3                             filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_3
                                                                                                                                                                                            Description
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                                                 After Iberian (method 4), non_iberian_counties excluded (method 4)
filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                                                                             After non_iberian_counties excluded (method 4)
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only                                                                                           After language and Iberian (method 1) location filters
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                                                            After Iberian filter (method 1), non_iberian_counties excluded (method 1)
filtered_iberian_common_NEW_ES_PT_regioncode_common_only                                                                                                                           After Iberian filter (method 1)
filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3         After keywords filter (include and not exclude), language (method 3) and Iberian (method 3) filters
filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3                               After keywords filter (included only), language (method 3) and Iberian (method 3) filters
filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only                                                                                         After keywords filter (include and not exclude)
filtered_included_only_common_NEW_ES_PT_regioncode_common_only                                                                                                                After keywords filter (include only)
filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3                                After keywords filter (exclude only), language (method 3) and Iberian (method 3) filters
filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                                           After keywords, language (method 3) and Iberian (method 3) location filters
filtered_language_common_NEW_ES_PT_regioncode_common_only_3                                                                                                                       After language filter (method 3)
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                          After language and Iberian (method 2) location filters, non_iberian_counties excluded (method 2)
filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3                                                                                                                       After keywords filter (method 3)
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2                                                                              After language (method 1) and Iberian (method 2) location filters
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                                                                     After language filter, non_iberian_counties excluded (method 1)
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                                                                   After language filter, non_iberian_counties excluded (method 2)
filtered_language_common_NEW_ES_PT_regioncode_common_only                                                                                                                         After language filter (method 1)
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                                                          After Iberian filter (method 2), non_iberian_counties excluded (method 2)
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2                                                                                                                         After Iberian filter (method 2)
filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only                                                                                                                After keywords filter (exclude only)
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4                                                                                                                         After Iberian filter (method 4)
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                                                              After language (method 3) and Iberian (method 3) location filters
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_3               After language (method 3) and Iberian (method 3) location filters, non_iberian_counties excluded (method 3)
                                                                                            Row_Count
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                0
filtered_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_4                                        0
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only                                              7
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                                 16
filtered_iberian_common_NEW_ES_PT_regioncode_common_only                                                      18
filtered_keywords_language_iberian_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only_3       480
filtered_keywords_language_iberian_included_only_common_NEW_ES_PT_regioncode_common_only_3                   480   *
filtered_included_and_not_excluded_common_NEW_ES_PT_regioncode_common_only                                   652   *
filtered_included_only_common_NEW_ES_PT_regioncode_common_only                                               670
filtered_keywords_language_iberian_excluded_only_common_NEW_ES_PT_regioncode_common_only_3                  2190
filtered_keywords_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                2190   *
filtered_language_common_NEW_ES_PT_regioncode_common_only_3                                                 2889
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                    3892   *
filtered_keywords_common_NEW_ES_PT_regioncode_common_only_3                                                 3914
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_2                                         3974
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only                              4115
filtered_language_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                            4116
filtered_language_common_NEW_ES_PT_regioncode_common_only                                                   4198
filtered_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_2                             5832   *   SELECTED
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_2                                                  5953
filtered_excluded_only_common_NEW_ES_PT_regioncode_common_only                                              6309
filtered_iberian_common_NEW_ES_PT_regioncode_common_only_4                                                  6431   *
filtered_language_iberian_common_NEW_ES_PT_regioncode_common_only_3                                           NA
filtered_language_iberian_non_iberian_counties_common_NEW_ES_PT_regioncode_common_only_3                      NA
                                                                             Row_Count

                                                                             


################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################### REGION CODE DATASETS - SCIENTIFIC + COMMON ################################################################################################################################################################# REGION CODE DATASETS - SCIENTIFIC + COMMON ################################################################################################################################################################# REGION CODE DATASETS - SCIENTIFIC + COMMON ##################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################

# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(cld2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)
library(officer)
library(readr)


final_region <- rbind(final_region_1,final_region_2,final_region_3,final_region_4,
                  final_region_5,final_region_6,final_region_7,final_region_8,
                  final_region_9,final_region_10,final_region_11,final_region_12,
                  final_region_13,final_region_14,final_region_15,final_region_16,
                  final_region_17,final_region_18,final_region_19,final_region_20,
                  final_region_21,final_region_22)

library(dplyr)

# Remove duplicates by video_id, title, and video_url
final_region_scientific_common_dedup <- final_region %>%
  distinct(video_id, title, video_url, .keep_all = TRUE)

# Check before/after
cat("Original rows:", nrow(final_region), "\n")
cat("Rows after removing duplicates:", nrow(final_region_scientific_common_dedup), "\n")

# Save if needed
write.csv(final_region_scientific_common_dedup, "yt_species_videos_ES_PT_regioncode_scientific_common_dedup.csv", row.names = FALSE)


################################################################################################### LIST OF SPECIES WITH SCIENTIFIC AND COMMON NAMES ########################################################

final_region_scientific_common_dedup <- read_csv("yt_species_videos_ES_PT_regioncode_scientific_common_dedup.csv")


# Your provided list
all_lists_NEW_ES_PT_regioncode_scientific_common <- list(
  "Aedes_japonicus" = c(
      "Aedes japonicus",
      "Mosquito del Japón",
      "Mosquito Japón",
      "Mosquito del Japon",
      "Mosquito Japon",
      "Mosquito asiático",
      "Mosquito asiatico",
      "Mosquito asiático de los arbustos",
      "Mosquito asiatico de los arbustos"
  ),

  "Apalone_ferox" = c(
      "Apalone ferox",
      "Tortuga de closca tova de Florida",
      "Tortuga closca tova de Florida",
      "Tortuga de caparazón blando de Florida",
      "Tortuga caparazón blando de Florida",
      "Tortuga de caparazon blando de Florida",
      "Tortuga caparazon blando de Florida",
      "Tartaruga americana de caco mole",
      "Tartaruga-americana-de-casco-mole",
      "Tartaruga-de-casco-mole-americana",
      "Tartaruga de caparazón brando da Florida",
      "Tartaruga caparazón brando da Florida"
  ),

  "Amazona_amazonica" = c(
      "Amazona amazonica",
      "Amazona d'ales carbassa",
      "Amazona carbassa",
      "Amazona de as laranxas",
      "Amazona de ás laranxas",
      "Amazona alinaranxa",
      "Amazona d'ales taronja",
      "Amazona taronja",
      "Papagai d'ales carbassa",
      "Lloro d'ales taronges",
      "Lloro taronges",
      "Amazona alinaranja",
      "Papagaio d'asa laranja",
      "Kuritzaká", "Kuritzaka"
  ),

  "Eupsittula_pertinax" = c(
      "Eupsittula pertinax",
      "Aratinga pertinax",
      "Aratinga pertinaz",
      "Aratinga de coroneta blava",
      "Aratinga coroneta blava",
      "Aratinga de cara castaña",
      "Aratinga cara castaña",
      "Aratinga caraparda",
      "Periquito bochecha parda",
      "Periquito de bochechas pardas",
      "Periquito de garganta castanha"
  ),

  "Aphis_illinoisensis" = c(
      "Aphis illinoisensis",
      "Aphis Aphis illinoisensis",
      "Pulgón de la vid",
      "Pulgon de la vid",
      "Pulgão-preto-da-videira",
      "Pulgão preto",
      "Pulgão preto videira"
  ),

  "Spatula_hottentota" = c(
      "Spatula hottentota",
      "Cerceta hotentote",
      "Cerceta de hottentot",
      "Cerceta hottentot",
      "Xarxet hotentot",
      "Cerceta joi",
      "Ànec hotentot",
      "Cerceta hotentote",
      "Ànec hotentot",
      "Cerceta hottentot",
      "Marrequinha bico azul",
      "Marrequinha-de-bico-azul",
      "Zertzeta hotentot"
  ),

  "Barbronia_weberi" = c(
      "Barbronia weberi",
      "Sanguijuela asiática de agua dulce",
      "Sanguijuela asiatica de agua dulce",
      "Sanguijuela asiática agua dulce",
      "Sanguijuela asiatica agua dulce"
  ),

  "Blastopsylla_occidentalis" = c(
      "Blastopsylla occidentalis",
      "Chicharrita del brote",
      "Piojo saltarín del eucalipto",
      "Piojo saltarín del ocalitu"
  ),

  "Chenonetta_jubata" = c(
      "Chenonetta jubata",
      "Pato de crin",
      "Pato de crina",
      "Ànec de crinera",
      "Ànec crinera",
      "Ganso de melena",
      "Ahate kalpardun"

  ),

  "Columbina_talpacoti" = c(
      "Columbina talpacoti",
      "Columbina colorada",
      "Rolinha púrpura",
      "Rolinha corada",
      "Tórtora terrestre rogenca",
      "Tortora terrestre rogenca",
      "Tierrerita"
  ),

  "Corvus_albus" = c(
      "Corvus albus",
      "Bele azpizuri",
      "Bele azpizuria",
      "Cuervo pio",
      "Corb pitblac",
      "Corb pitblanc",
      "Corvo de coleira",
      "Corb pit blanc",
      "Corvo pego",
      "Bele azpizuri",
      "Corb blanc i negre",
      "Corb de pit blanc",
      "Cuervu píu",
      "Corvo-de-barriga-branca",
      "Gralha-seminarista",
      "Cuervu piu",
      "Erroi azpizuri"
  ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis"
  ),

  "Cygnus_melancoryphus" = c(
      "Cygnus melancoryphus",
      "Cigne coll negre",
      "Cisne cuellinegro",
      "Cisne cuello negro",
      "Cigne de coll negre",
      "Cisne de pescuezu prietu",
      "Cisne de pescuezu-prietu",
      "Cisne de pescoço preto",
      "Cisne-de-pescoço-preto",
      "Cisne de pescozo negro",
      "Beltxarga lepabeltz",
      "Beltxarga lepabeltza"
  ),

  "Dryocosmus_kuriphilus" = c(
      "Dryocosmus kuriphilus",
      "Avispilla del castaño",
      "Avispilla asiática del castaño",
      "Avispilla asiatica del castaño",
      "Cinipídeo do castanheiro",
      "Avespa do castiñeiro"
  ),

  "Gobio_occitaniae" = c(
      "Gobio occitaniae",
      "Gobio occitano"
  ),

  "Equisetum_palustre" = c(
      "Equisetum palustre",
      "Cola de caballo de los pantanos",
      "Cola de caballo de pantano",
      "Cavalinha do pântano",
      "Cavalinha do pantano",
      "Equiset palustre"
  ),

  "Graptemys_pseudogeographica" = c(
      "Graptemys pseudogeographica",
      "Testudo_geographica",
      "Emys geographica",
      "Malaclemys georgraphica",
      "Tortuga mapa falsa",
      "Tortuga falsa mapa",
      "Tortuga mapa del Mississipi",
      "Falsa corcunda do Mississippi",
      "Tartaruga falsa-corcunda",
      "Tartaruga corcunda do Mississipi",
      "Tartaruga falsa corcunda do Mississipi"
  ),

  "Grus_canadensis" = c(
      "Grus canadensis",
      "Antigone canadensis",
      "Ardea canadensis",
      "Grulla canadiense",
      "Grua del Canadà",
      "Grua del Canada",
      "Grou-americano",
      "Grou do Canadá",
      "Kurrilo kanadar",
      "Kurrilo kanadarra",
      "Grúa canadiana",
      "Grua canadiana",
      "Grou canadiano",
      "Grus proavus"
  ),


  "Haemorhous_mexicanus" = c(
      "Haemorhous mexicanus",
      "Carpodacus mexicanus",
      "Pinzón mexicano",
      "Pinzon mexicano",
      "Camachuelo mejicano",
      "Camachuelo mexicano",
      "Carpodaco doméstico",
      "Carpodaco domestico",
      "Pintarroxo mexicano",
      "Picaflor mexicanu",
      "Pinsà casolà",
      "Pinsà casola",
      "Pinsa casola",
      "Pinsà mexicà",
      "Pintarroxo caseiro",
      "Pintarroxo do deserto",
      "Burugorri arrunt",
      "Burugorri arrunta"
  ),

  "Haliaeetus_leucocephalus" = c(
      "Haliaeetus leucocephalus",
      "Águila americana",
      "Aguila americana",
      "Pigargo americano",
      "Pigargo cabeza branca",
      "Pigargo cabeza blanca",
      "Pigargo de cabeza blanca",
      "Pigargo de cabeza branca",
      "Aguila de cap blanc",
      "Àguila cap blanc",
      "Àguila de cap blanc",
      "Pigarg americà",
      "Itsas arrano buruzuri",
      "Itsas arrano buruzuria",
      "Arrano buruzuri",
      "Arrano buruzuria",
      "Águia-americana",
      "Águia-de-cabeça-branca",
      "Itsas buruzuri",
      "Itsas buruzuria"
  ),

  "Ictalurus_punctatus" = c(
      "Ictalurus punctatus",
      "Silurus punctatus",
      "Peix gat americà",
      "Pez gato americano",
      "Bagre_americano",
      "Bagre de canal",
      "Bagre del canal",
      "Peixe gato americano",
      "Pez gato punteado",
      "Bagre canal"
  ),

  "Leuciscus_aspius" = c(
      "Leuciscus_aspius",
      "Aspio"
  ),

  "Lorius_chlorocercus" = c(
      "Lorius chlorocercus",
      "Lori acollarado",
      "Lori collar groc",
      "Lori de collar groc",
      "Lóris-de-colar-amarelo",
      "Lóris colar amarelo",
      "Loris de colar amarelo",
      "Loris colar amarelo",
      "Lóri-de-colar-amarelo"
  ),

  "Macrochelys_temminckii" = c(
      "Macrochelys temminckii",
      "Tortuga caimán",
      "Tortuga caiman",
      "Tortuga aligator",
      "Tortuga cocodrilo mordedora",
      "Tartaruga aligátor",
      "Tartaruga aligator",
      "Tartaruga mordedora de cocodrilo"
  ),

  "Maeotias_marginata" = c(
      "Maeotias marginata",
      "Hidromedusa de agua salobre",
      "Hidromedusa agua salobre",
      "Medusa del mar Negro"
  ),

  "Marisa_cornuarietis" = c(
      "Marisa cornuarietis",
      "Caracol cuerno de carnero gigante",
      "Caracol cuerno carnero gigante",
      "Caracol cuerno gigante de borrego",
      "Caracol cuerno gigante borrego",
      "Caracol cuerno de carnero",
      "Caracol cuerno carnero",
      "Caracol cuerno borrego",
      "Caracol colombiano",
      "Caragol banya de carner gegant",
      "Caragol colombià"
  ),

  "Microlepia_platyphylla" = c(
      "Microlepia platyphylla"
  ),

  "Mimus_gilvus" = c(
      "Mimus gilvus",
      "Sinsonte tropical",
      "Sinsont tropical",
      "Mim de sabana",
      "Mim de les sabanes",
      "Imitador tropical",
      "Pájaro imitador tropical",
      "Mirla blanca",
      "Sabiá-da-praia",
      "Sabia da praia",
      "Mimo-tropical",
      "Mimu tropical",
      "Tordo-imitador-da-praia",
      "Zentzuntle tropikal"
  ),

  "Musophaga_violacea" = c(
      "Musophaga violacea",
      "Turaco violáceo",
      "Turaco violaceo",
      "Turac violaci",
      "Turaco violeta",
      "Turacu violaceu",
      "Turako bioleta",
      "Pavão-azul"
  ),

  "Netta_peposaca" = c(
      "Netta peposaca",
      "Pato peposaca",
      "Xibec peposaca",
      "Peposaka ahate",
      "Peposaka ahatea",
      "Zarro patagónico",
      "Parrulo patagónico"
  ),

  "Obolodiplosis_robiniae" = c(
      "Obolodiplosis robiniae",
      "Mosquito de las agallas de la robinia"
  ),

  "Orientogalba viridis" = c(
      "Orientogalba viridis",
      "Austropeplea viridis",
      "Lymnaea viridis",
      "Radix viridis",
      "Austropeplea viridis",
      "Caracol anfibio de agua dulce"
  ),

  "Ommatotriton_ophryticus" = c(
      "Ommatotriton ophryticus",
      "Tritón crestado turco",
      "Tritón con bandas del norte",
      "Tritón bandas norte",
      "Tritão-de-banda-do-Norte",
      "Tritó caucàsic",
      "Triton ophryticus",
      "Triturus ophryticus"
  ),

  "Palaemon_macrodactylus" = c(
      "Palaemon macrodactylus",
      "Camarón emigrante", "Camarón-emigrante", "Camarón_emigrante"
  ),

  "Pelodiscus_sinensis" = c(
      "Pelodiscus sinensis",
      "Tortuga china de caparazón blando",
      "Tortuga china de caparazon blando",
      "Tortuga china caparazón blando",
      "Tortuga china caparazon blando",
      "Tortuga china de concha blanda",
      "Galápago de conchablanda chino",
      "Galapago de conchablanda chino",
      "Galápago conchablanda chino",
      "Galápago de concha blanda chino",
      "Galapago de concha blanda chino",
      "Tortuga de caparazón blando china",
      "Tortuga de caparazon blando china",
      "Tartaruga-de-carapaça-mole-chinesa",
      "Tartaruga carapaça mole chinesa",
      "Tortuga de cloca tova xinesa",
      "Tortuga de petxina tova xinesa",
      "Tortuga de cloaca tova xinesa",
      "Tartaruga chinesa de caparazón brando"
  ),

  "Perca_fluviatilis" = c(
      "Perca fluviatilis",
      "Perca río",
      "Perca rio",
      "Perca ríu",
      "Perca riu",
      "Perca de río",
      "Perca de rio",
      "Perca europea",
      "Perca euraiática",
      "Perca euraiatica",
      "Perca de ríu",
      "Perca de riu",
      "Perca común",
      "Perca comun",
      "Perka arrunta",
      "Perka arrunt",
      "Perca europeia"
  ),

  "Phoeniculus_purpureus" = c(
      "Phoeniculus purpureus",
      "Puput dels arbres verd",
      "Abubilla arbórea verde",
      "Abubilla arborea verde",
      "Abubilla verde",
      "Puput dels arbres verda",
      "Puput arbres verda",
      "Puput arbòria verda",
      "Puput arboria verda",
      "Zombeteiro purpúreo",
      "Zombeteiro purpureo",
      "Zombeteiro de bico vermelho"
  ),

  "Platycerium_bifurcatum" = c(
      "Platycerium bifurcatum",
      "Cuerno de alce",
      "Falguera banya",
      "Falguera banya d'ant",
      "Banya d'Ant",
      "Banya de cérvol",
      "Cacho de venado",
      "Cacho venado",
      "Cachovenado",
      "Helecho cuerno",
      "Helecho cuerno de alce",
      "Helecho de ciervo",
      "Helecho ciervo",
      "Helecho cuerno de ciervo",
      "Helecho cuerno de venado",
      "Helecho de alce",
      "Staghorn iratzea"
  ),

  "Pseudemys_concinna" = c(
      "Pseudemys concinna",
      "Tortuga jeroglífico",
      "Tortuga jeroglifico",
      "Tortuga jeroglífica",
      "Tartaruga hieroglífica",
      "Tartaruga hieroglifica",
      "Tortuga hieroglyphica"
  ),

  "Psittacus_erithacus" = c(
      "Psittacus erithacus",
      "Loro yaco",
      "Yaco de cola roja",
      "Yaco cola roja",
      "Loro gris de cola roja",
      "Loro gris cola roja",
      "Loro gris africano",
      "Loro gris africano de cola roja",
      "Lloro gris",
      "Lloro gris cuavermell",
      "Lloro gris cua-roig",
      "Lloro gris africà",
      "Lloro cuavermell",
      "Papagaio-cinzento",
      "Papagaio-do-congo",
      "Loro gris afrikarra",
      "Loru gris africanu"
  ),

  "Psyllaephagus_bliteus" = c(
      "Psyllaephagus bliteus"
  ),

  "Rhodospiza_obsoleta" = c(
      "Rhodospiza obsoleta",
      "Camachuelo desertícola",
      "Camachuelo deserticola",
      "Pinsà rosat del desert",
      "Pinsa rosat del desert",
      "Pinsà del desert",
      "Pinsa del desert",
      "Pimpín do deserto",
      "Pimpin do deserto",
      "Pintarroxo do deserto",
      "Verdilhão do deserto",
      "Verdilhao-do-deserto",
      "Basamortuko txonta"
  ),

  "Sipha_flava" = c(
      "Sipha flava",
      "Pulgón amarillo de la caña de azúcar",
      "Pulgón amarillo de la caña de azucar",
      "Pulgon amarillo de la caña de azucar",
      "Pulgón amarillo de caña de azúcar",
      "Pulgón amarillo de caña de azucar",
      "Pulgon amarillo de caña de azucar",
      "Pulgão-amarelo-da-cana-de-açúcar",
      "Pulgão-amarelo-da-cana-de-açucar",
      "Pulgón amarillo azúcar",
      "Pulgon amarillo azúcar",
      "Pulgon amarillo azucar",
      "Pugó groc de la canya de sucre"
  ),

  "Stenopelmus_rufinasus" = c(
      "Stenopelmus rufinasus"
  ),

  "Styela_plicata" = c(
      "Styela plicata",
      "Patata de mar",
      "Patata de Mer"
  ),

  "Testudo_marginata" = c(
      "Testudo marginata",
      "Tortuga marginada",
      "Tortuga almenada",
      "Dortoka ertz zabal",
      "Dortoka ertz zabala",
      "Tartaruga marginata"
  ),

  "Tockus_deckeni" = c(
      "Tockus deckeni",
      "Toco keniata",
      "Toco de Von der Decken",
      "Toco Von der decken",
      "Calau de von der decken",
      "Calau Decken",
      "Calau de Decken"
  ),

  "Trachemys_emolli" = c(
      "Trachemys emolli",
      "Tortuga nicaragüene",
      "Tortuga nicaraguense",
      "Tortuga escurridiza de Nicaragua",
      "Tartaruga de Nicaragua",
      "Tartaruga da Nicarágua"
  ),

  "Vespa_velutina" = c(
      "Vespa velutina",
      "Avispa asiática",
      "Avispa asiatica",
      "Avispa negra asiática",
      "Avispa negra asiatica",
      "Avispón negro asiático",
      "Avispón negro asiatico",
      "Avispon negro asiático",
      "Avispon negro asiatico",
      "Avispa asiática gigante",
      "Avispa asiatica gigante",
      "Vespa carnissera asiàtica",
      "Vespa carnissera asiatica",
      "Avespa asiática",
      "Avespa asiatica",
      "Vespa asiàtica",
      "Vespa asiatica",
      "Vespão asiático",
      "Vespão asiatico",
      "Vespa carnicera asiàtica",
      "Vespa carnicera asiatica",
      "Avispa asesina",
      "Liztor asiarrra",
      "Liztor asiar",
      "Asiako liztor beltza"
  ),

  "Zenaida_meloda" = c(
      "Zenaida meloda",
      "Zenaida peruana",
      "Tórtora de costa",
      "Paloma cuculina",
      "Rola-do-pacífico"
  ),

  "Lepisiota_capensis" = c(
      "Lepisiota capensis",
      "Hormiga azucarera africana"
  ),

  "Neotoxoptera_formosana" = c(
      "Neotoxoptera formosana",
      "Pulgón de la cebolla",
      "Pulgon de la cebolla",
      "Pulgão da cebola"
  ),

  "Phthorimaea_absoluta" = c(
      "Phthorimaea absoluta",
      "Tuta absoluta",
      "Cogollero del tomate",
      "Gusano minador del tomate",
      "Minador de hojas y tallos de la papa",
      "Minador de la hoja del tomate",
      "Polilla del tomate",
      "Palomilla del tomate",
      "Arna de la tomaca",
      "Arna del tomàquet",
      "Arna del tomaquet",
      "Arna tomàquet",
      "Arna tomaquet",
      "Couza do tomate",
      "Cuc minador del tomaca",
      "Cuc del tomàquet",
      "Cuc del tomaquet",
      "Avelaíña do tomate",
      "Tomatearen sitsa",
      "Traça-do-tomateiro",
      "Traça tomateiro"
  ),

  "Puto_barberi" = c(
      "Puto barberi",
      "Cochinilla blanca de la raíz",
      "Cochinilla blanca de la raiz",
      "Cochinilla del café",
      "Cochinilla del cafe",
      "Cochinilla gigante de Barber",
      "Cochinilla gigante Barber"
  ),

  "Lonchura_oryzivora" = c(
      "Lonchura oryzivora",
      "Capuchino arrocero de Java",
      "Gorrión de Java",
      "Gorrion de Java",
      "Maniquí galtablanc",
      "Maniqui galtablanc",
      "Maniquí de Java",
      "Maniqui de Java",
      "Pardal de java",
      "Pardal de Java",
      "Pardal de Xava",
      "Padda de Java"
  ),

  "Neophema_pulchella" = c(
      "Neophema pulchella",
      "Periquito turquesa"
  ),

  "Camponotus_compressus" = c(
      "Camponotus compressus"
  ),

  "Epidiplosis_filifera" = c(
      "Epidiplosis filifera"
  ),

  "Penthimiola_bella" = c(
      "Penthimiola bella"
  ),

  "Schizoporella_errata" = c(
      "Schizoporella errata"
  ),

  "Stenothoe_georgiana" = c(
      "Stenothoe georgiana"
  ),


  "Hercinothrips_dimidiatus" = c(
      "Hercinothrips dimidiatus"
  ),

  "Hydrocharis_laevigata" = c(
      "Hydrocharis laevigata"
  ),

  "Branta_canadensis" = c(
      "Branta canadensis",
      "Barnacla canadiense",
      "Barnacla canadiense grande",
      "Oca del Canadà",
      "Ganso-do-Canadá",
      "Ganso-do-Canada",
      "Gansu canadianu",
      "Gansu canadiense",
      "Gansu de Canada",
      "Branta kanadar",
      "Branta kanadar handi",
      "Branta kanadarra",
      "Kanadako branta"
  ),

  "Bosmina_coregoni" = c(
      "Bosmina coregoni",
      "Eubosmina coregoni"
  ),

  "Geranoaetus_melanoleucus" = c(
      "Geranoaetus melanoleucus",
      "Águila mora",
      "Águila escudada",
      "Àguila pitnegra",
      "Aguila mora",
      "Aguila escudada",
      "Aguila pitnegra",
      "Águila escudada",
      "Àguila escudada",
      "Águia serrana",
      "Bútio-de-peito-preto",
      "BUtio-de-peito-preto",
      "Zapelatz paparbeltz",
      "Zapelatz paparbeltza"
   ),

  "Geranoaetus_polyosoma" = c(
      "Geranoaetus polyosoma",
      "Busardo dorsirrojo",
      "Aligot tricolor",
      "Bútio-de-dorso-vermelho",
      "Butio-de-dorso-vermelho",
      "Bútio variável",
      "Zapelatz aldakor",
      "Zapelatz aldakorra"
   ),

   "Hypoponera_ergatandria" = c(
      "Hypoponera ergatandria"
   ),

   "Leptoglossus_occidentalis" = c(
      "Leptoglossus occidentalis",
      "Chinche americana del pino",
      "Chinche americana de pino",
      "Chinche americano del pino",
      "Chinche americano de pino",
      "Chinche americana de las piñas",
      "Chinche de las piñas",
      "Xinxa americana del pi",
      "Xinxa americana dels pins",
      "Xinxa americana del pins",
      "Inseto pinheiro americano"
   ),

    "Lobiopa_insularis" = c(
      "Lobiopa insularis"
   ),

  "Crangonyx_pseudogracilis" = c(
      "Crangonyx pseudogracilis",
      "Pulga de agua del norte",
      "Pulga-de-água-do-norte",
      "Pulga-de-Agua-do-norte",
      "Pulga água do norte"
  ),

  "Carassius_gibelio" = c(
      "Carassius gibelio",
      "Carpa prusiana",
      "Carpa prussiana",
      "Carpa prussiana prateada",
      "Carpa-prusiana-prateada",
      "Pimpão cinzento"
  ),

  "Chrysonotomyia_chamaeleon" = c(
      "Chrysonotomyia chamaeleon"
  ),

   "Epitrix_similaris" = c(
      "Epitrix similaris",
      "Pulguilla de la patata",
      "Pulguilla de patata",
      "Pulguilla de la papa",
      "Pulga saltona",
      "Pulguilla saltona"
   ),

   "Glycaspis_brimblecombei" = c(
      "Glycaspis brimblecombei",
      "Psílido del eucalipto rojo",
      "Psílido rojo del eucalipto",
      "PsIlido del eucalipto rojo",
      "PsIlido rojo del eucalipto",
      "Conchuela australiana del eucalipto",
      "Conchuela del eucalipto"
   ),

   "Pezothrips_kellyanus" = c(
      "Pezothrips kellyanus",
      "Trips de los cítricos de Kelly",
      "Trips de los cítricos",
      "Trips de los citricos de Kelly",
      "Trips de los citricos",
      "Trips dels cítrics"
   ),

   "Pomacea_maculata" = c(
      "Pomacea maculata",
      "Pomacea insularum",
      "Caracol manzana gigante",
      "Caracol mazá xigante",
      "Cargol poma tacat",
      "Cargol poma gegant"
   ),

   "Sophonia_orientalis" = c(
      "Sophonia orientalis",
      "Chicharrita asiática de dos manchas",
      "Chicharrita asiatica de dos manchas"
   ),

   "Agapornis_fischeri" = c(
      "Agapornis fischeri",
      "Inseparable de Fischer",
      "Inseparábel de Fischer",
      "Inseparabel de Fischer",
      "Inseparável de fischer",
      "Inseparavel de fischer",
      "Agapornis de Fischer",
      "Inseparável-alaranjado"
   ),

  "Lasius_neglectus" = c(
      "Lasius neglectus",
      "Hormiga invasora de jardines",
      "Hormiga invasora de los jardines",
      "Hormiga de jardín invasora",
      "Formiga invasora de jardins",
      "Formiga invasora dels jardins",
      "Formiga de jardí invasora",
      "Formiga de xardín invasora",
      "Formiga invasora de jardim"
  ),

  "Paratrechina_jaegerskioeldi" = c(
      "Nylanderia jaegerskioeldi",
      "Paratrechina jaegerskioeldi",
      "Prenolepis fulva",
      "Hormiga loca",
      "Formiga boja"
  ),

   "Pheidole_indica" = c(
      "Pheidole indica",
      "Pheidole teneriffana",
      "Hormiga cabezona india"
   ),

   "Pheidole_megacephala" = c(
      "Pheidole megacephala",
      "Hormiga leona",
      "Hormiga africana cabezona",
      "Hormiga cabezona africana",
      "Formiga africana cabezona",
      "Formiga africana de cabeça grande",
      "Formiga africana cabezuda",
      "Formiga cabezuda africana",
      "Hormiga cabezona africana"
   ),

   "Strumigenys_silvestrii" = c(
      "Strumigenys silvestrii"
   ),

   "Mnemiopsis_leidyi" = c(
      "Mnemiopsis leidyi",
      "Medusa bombilla",
      "Ctenóforo americano",
      "Medusa bombeta",
      "Anou de mar"
   ),

    "Anoplolepis_gracilipes" = c(
      "Anoplolepis gracilipes",
      "Hormiga zancona",
      "Hormiga loca amarilla",
      "Hormiga loca amarilla africana",
      "Hormiga loca amarilla de África",
      "Hormiga loca amarilla de Africa",
      "Formiga boja groga",
      "Formiga louca amarela",
      "Formiga tola amarela"
    ),

    "Planorbella_duryi" = c(
      "Planorbella duryi",
      "Helisoma duryi",
      "Planorbis de Florida"
    ),

    "Pseudosuccinea_columella" =c(
      "Pseudosuccinea columella",
      "Caracol americano de los trematodos",
      "Caracol americano de trematodos",
      "Caracol de la duela del hígado"
    ),

    "Pseudodiaptomus_marinus" = c(
      "Pseudodiaptomus marinus"
    ),

    "Faxonius_limosus" = c(
      "Faxonius limosus",
      "Orconectes limosus",
      "Cangrejo de los canales",
      "Cangrejo de río de los canales",
      "Cangrejo río de los canales",
      "Cangrejo de rio de los canales",
      "Cangrejo rio de los canales",
      "Cangrejo de canales",
      "Cranc dels canals",
      "Cranc del riu dels canals"
     ),

     "Primolius_auricollis" = c(
      "Primolius auricollis",
      "Guacamayo acollarado",
      "Guacamaya cuello dorado",
      "Guacamaya de cuello dorado",
      "Maracanã-de-colar",
      "Guacamai colldaurat",
      "Arara-de-colar-dourado"
     ),

     "Hemicypris_barbadensis" = c(
      "Hemicypris barbadensis"
     ),

     "Hemicypris_reticulata" = c(
      "Hemicypris reticulata"
     ),

     "Delottococcus_aberiae" = c(
      "Delottococcus aberiae",
      "Cottonet de les Valls",
      "Cottonet de Valls",
      "Cotonet de les Valls",
      "Cotonet de Valls",
      "Cotonet de Sudáfrica",
      "Cotonet de Sudafrica"
     ),

     "Aratinga_jandaya" = c(
      "Aratinga jandaya",
      "Aratinga jandaia",
      "Cotorra jandaya",
      "Jandaia-verdadeira",
      "Periquitão-nordestino"
      ),

     "Belonochilus_numenius" = c(
      "Belonochilus numenius",
      "Chinche del sicomoro",
      "Chinche del sicómoro",
      "Chinche de la semilla del sicómoro",
      "Chinche de la semilla del sicomoro"
      ),

     "Cereopsis_novaehollandiae" = c(
      "Cereopsis novaehollandiae",
      "Ganso cenizo",
      "Ganso ceniciento",
      "Oca cendrosa",
      "Ganso cinzento australiano",
      "Ganso cinzento",
      "Antzara hauskara"
      ),

     "Brachymyrmex_patagonicus" = c(
      "Brachymyrmex patagonicus",
      "Hormiga rover oscura",
      "Hormiga rover negra"
      ),

     "Brachymyrmex_heeri" = c(
      "Brachymyrmex heeri"
      ),

     "Cardiocondyla_obscurior" = c(
      "Cardiocondyla obscurior"
      ),

     "Blechnum_occidentale" = c(
      "Blechnum occidentale"
      ),

     "Anas_flavirostris" = c(
      "Anas flavirostris",
      "Marreca-pardinha",
      "Marrequinha-de-bico-amarelo",
      "Cerceta barcina",
      "Xarxet becgroc",
      "Zertzeta mokohori"
      ),

     "Vespa_orientalis" = c(
      "Vespa orientalis",
      "Vespa oriental",
      "Avispón oriental",
      "Avispon oriental",
      "Avispa oriental"
      ),

     "Tapinoma_melanocephalum" = c(
      "Tapinoma melanocephalum",
      "Hormiga fantasma",
      "Hormiga boticaria",
      "Formiga fantasma"
      ),

     "Tapinoma_pallipes" = c(
      "Tapinoma pallipes"
      ),

     "Anser_cygnoides" = c(
      "Anser cygnoides",
      "Ánsar cisnal",
      "Ansar cisnal",
      "Oca cigne",
      "ánsar cisne",
      "Ansar cisne",
      "Ganso cisnal",
      "Ganso cisne",
      "Ganso africano",
      "Ganso chinês",
      "Beltxarga antzara"
      ),

    "Balistoides_conspicillum" = c(
     "Balistoides conspicillum",
     "Pez ballesta payaso",
     "Pez ballesta payasu",
     "Peixe ballesta pallaso",
     "Peix ballesta pallasso",
     "Peixe-porco-palhaço",
     "Cangulo palhaço"
     ),

    "Duttaphrynus_melanostictus" = c(
     "Duttaphrynus melanostictus",
     "Sapo común asiático",
     "Sapo comun asiatico",
     "Sapo comun asiático",
     "Sapo común asiatico",
     "Sapo comum asiático",
     "Sapo comum asiatico",
     "Sapu común asiáticu",
     "Gripau comú asiàtic",
     "Gripau comú asiatic",
     "Gripau comu asiàtic"
     ),

    "Varanus_exanthematicus" = c(
     "Varanus exanthematicus",
     "Lacerta exanthematicus",
     "Varanus ocellatus",
     "Varano de sabana",
     "Varano de la sabana",
     "Varano de Bosc",
     "Varano de bosc",
     "Varà de sabana",
     "Varà de Bosc",
     "Varano terrestre africano",
     "Varano das savanas",
     "Monitor de savana",
     "Monitor de la sabana",
     "Monitor de sabana"
     ),

    "Vespa_soror" = c(
     "Vespa soror",
     "Avispón sóror",
     "Avispon sóror",
     "Avispón soror",
     "Avispon soror",
     "Avispón gigante del sur",
     "Avispon gigante del sur",
     "Avispa gigante del sur",
     "Vespa gegant del sud",
     "Avispón xigante do sur",
     "Avispon xigante do sur",
     "Vespa-gigante-do-sul"
     ),

    "Vespa_bicolor" = c(
     "Vespa bicolor",
     "Avispa bicolor",
     "Avispón bicolor",
     "Avispon bicolor",
     "Avispa escudo negro",
     "Avispón de escudo negro",
     "Avispón escudo negro",
     "Avispon de escudo negro",
     "Avispon escudo negro"
    ),

    "Lagocephalus_sceleratus" = c(
     "Lagocephalus sceleratus",
     "Piraña del Mediterráneo",
     "Pez sapo de mejillas plateadas",
     "Pez globo plateado",
     "Peixe-balão sapo-de-bochecha-prateada",
     "Peixe-balão-sapo-de-bochecha-prateada",
     "Peixe-balão prateado",
     "Peixe-balão-prateado",
     "Peixe-sapo de bochechas prateadas"
     ),

    "Zebrasoma_flavescens" = c(
     "Zebrasoma flavescens",
     "Acanthurus flavescens",
     "Pez cirujano amarillo",
     "Navajón velero amarillo",
     "Peix cirurgià groc",
     "Cirurgião-amarelo",
     "Peixe-cirurgião-amarelo"
     ),

   "Trachymela_sloanei" = c(
    "Trachymela sloanei",
    "Escarabajo tortuga australiano",
    "Besouro-tartaruga australiano",
    "Besouro-tartaruga-de-eucalipto",
    "Besouro-tartaruga de eucalipto"
     ),

   "Xylotrechus_chinensis" = c(
    "Xylotrechus chinensis",
    "Escarabajo avispa taladro de las moreras",
    "Escarabajo-avispa taladro de las moreras",
    "Escarabajo perforador de las moreras",
    "Escarabajo-avispa barrenador de las moreras",
    "Escarabat vespa barrinador de les moreres",
    "Escarabat vespa barrinador de moreres",
    "Escarabat-vespa barrinador de moreres",
    "Escarabat barrinador de les moreres",
    "Escarabat-barrinador de les moreres",
    "Escarabat vespa escombrador de les moreres",
    "Escarabat-vespa escombrador de les moreres"
     ),

   "Paracoccus_burnerae" = c(
    "Paracoccus burnerae",
    "Cochinilla de la adelfa"
     ),

   "Macrohomotoma_gladiata" = c(
    "Macrohomotoma gladiata",
    "Psila del ficus",
    "Psil·la del ficus",
    "Psilla del ficus"
     ),

   "Paracaprella_pusilla" = c(
    "Paracaprella pusilla"
     ),

   "Caprella_scaura" = c(
    "Caprella scaura",
    "Gamba esqueleto",
    "Gamba fantasma"
     ),

   "Dyspanopeus_sayi" = c(
    "Dyspanopeus sayi",
    "Cangrejo marino americano",
    "Cranc marí americà",
    "Pequeño cangrejo de barro"
     ),

   "Megabalanus_tintinnabulum" = c(
    "Megabalanus tintinnabulum",
    "Balanus tintinnabulum",
    "Percebe bellota"
     ),

   "Solidobalanus_fallax" = c(
    "Solidobalanus fallax"
     ),

   "Vanellus senegallus" = c(
    "Vanellus senegallus",
    "Avefría senegalesa",
    "Avefría del Senegal",
    "Fredeluga del Senegal",
    "Fredeluga senegalesa",
    "Avefría do Senegal",
    "Abibe carunculado",
    "Abibe carúncula",
    "Abibe caruncula"
     ),

   "Chloephaga_picta" = c(
    "Chloephaga picta",
    "Cauquén común",
    "Cauquen común",
    "Cauquén comun",
    "Cauquen comun",
    "Cauquén magallánico",
    "Cauquén magallanico",
    "Cauquen magallánico",
    "Cauquen magallanico",
    "Oca de Magallanes",
    "Ganso patagónico",
    "Ganso-magalhânico",
    "Ganso magallánico",
    "Ganso de Magallanes",
    "Avutarda magallánica",
    "Avutarda de Magallanes",
    "Magallaesko antzara",
    "Magallanes antzarra"
     ),

   "Acridotheres_ginginianus" = c(
    "Acridotheres ginginianus",
    "Miná ribereño",
    "Minà de ribera",
    "Minà fosc",
    "Mainá ribeiriño",
    "Mainá oscura",
    "Mainà riberenc"
     ),

   "Psilopsiagon_aymara" = c(
    "Psilopsiagon aymara",
    "Catita aimará",
    "Cotorreta encaputxada",
    "Periquito-da-serra",
    "Periquito-aimara"
     ),

   "Elanoides_forficatus" = c(
    "Elanoides forficatus",
    "Elanio tijereta",
    "Esparver cuaforcat",
    "Milà de cua forcada",
    "Elani cuaforcat",
    "Elano mir-buztanduna",
    "Elano miru-buztan",
    "Elano miru buztana",
    "Gabián tesoira",
    "Gavião-tesoura",
    "Falcão-tesoura"
     ),

   "Platalea_ajaja" = c(
    "Platalea ajaja",
    "Espátula rosada",
    "Becplaner rosat",
    "Cullereiro americano",
    "Cullereiro rosa",
    "Colhereiro-americano",
    "Colhereiro-rosado",
    "Mokozabal arrosa"
     ),

   "Caloenas_nicobarica" = c(
    "Caloenas nicobarica",
    "Paloma de Nicobar",
    "Paloma Nicobar",
    "Colom de les illes Nicobar",
    "Colom de les Nicobar",
    "Colom de Nicobar",
    "Pombo-de-nicobar",
    "Pombo Nicobar"
     ),

   "Bycanistes_brevis" = c(
    "Bycanistes brevis",
    "Cálao cariplateado",
    "Calau de galtes argentades",
    "Calau galtaargentat",
    "Calau galtes argentades",
    "Calau-de-faces-prateadas",
    "Calau-de-face-prateada",
    "Calau-faces-prateadas",
    "Calau-face-prateada"
     ),

   "Caracara_plancus" = c(
    "Caracara plancus",
    "Caracara carancho",
    "Carancho meridional",
    "Caracarà crestat meridional",
    "Caracarà crestat",
    "Caracara-de-crista",
    "Carcará-de-poupa",
    "Karakara mottodun"
     ),

   "Theora_lubrica" = c(
    "Theora lubrica"
     ),

   "Atriplex_semilunaris" = c(
    "Atriplex semilunaris"
     ),

   "Pluchea_carolinensis" = c(
    "Pluchea carolinensis",
    "Ciguapate"
     ),

   "Axonopus_fissifolius" = c(
    "Axonopus fissifolius",
    "Hierba de alfombra común",
    "Hierba de alfombra comun",
    "Grama brasilera"
     ),

   "Eucheilota_menoni" = c(
    "Eucheilota menoni"
     ),

   "Branchiomma_bairdi" = c(
    "Branchiomma bairdi"
     ),

   "Perinereis_linea" = c(
    "Perinereis linea"
     ),

   "Perophora_japonica" = c(
    "Perophora japonica",
    "Tunicado del Indopacífico",
    "Tunicado Indopacífico",
    "Tunicado Indo-Pacífico",
    "Tunicado del Indopacifico",
    "Tunicado Indopacifico",
    "Tunicado Indo-Pacifico"
     ),

   "Ensis_leei" = c(
    "Ensis leei",
    "Almeja navaja del Atlántico"
     ),

   "Marginella_glabella" = c(
    "Marginella glabella"
     ),

   "Sus_scrofa_var_domestica_raza_vietnamita" = c(
    "Sus scrofa var. domestica raza vietnamita",
    "Cerdo vietnamita",
    "Porc vietnamita",
    "Porco vietnamita",
    "Vietnamgo txerria"
     ),

   "Ferrissia_californica" = c(
    "Ferrissia californica",
    "Lapa de agua dulce americana",
    "Lapa de água doce americana"
     ),

   "Reticulitermes_flavipes" = c(
    "Reticulitermes flavipes",
    "Termita subterránea oriental",
    "Termita subterranea oriental",
    "Tèrmit subterrània oriental",
    "Termit subterrània oriental",
    "Cupim subterrâneo",
    "Cupim subterraneo"
     ),

   "Acizzia_jamatonica" = c(
    "Acizzia jamatonica",
    "Psila de la albicia",
    "Psilla dell'albizia",
    "Psyla de albizia",
    "Psyla de la albizia"
    ),

   "Acridotheres_cristatellus" = c(
    "Acridotheres cristatellus",
    "Mina moñudu",
    "Minà crestat",
    "Miná crestado",
    "Estornino crestado",
    "Mainá-de-crista",
    "Mainato cristado",
    "Mainá-de-crista",
    "Mainato-de-poupa",
    "Hartxori gangarduna"
    ),

   "Agapornis_nigrigenis" = c(
    "Agapornis nigrigenis",
    "Inseparable cachetón",
    "Inseparable de mejillas negras",
    "Agapornis musubeltza",
    "Agapornis musubeltz",
    "Agapornis galtanegre",
    "Inseparable galtanegre",
    "Agapornis de galtes negres",
    "Inseparable de galtes negres",
    "Inseparável-de-faces-pretas"
    ),

   "Amazona_albifrons" = c(
    "Amazona albifrons",
    "Amazona frentialba",
    "Amazona de front blanc",
    "Papagai frontblanc",
    "Amazona frontblanca",
    "Papagaio-de-testa-branca"
    ),

   "Amazona_farinosa" = c(
    "Amazona farinosa",
    "Papagai farinós",
    "Papagai farinós meridional",
    "Amazona harinosa",
    "Amazona farinosa",
    "Papagaio-moleiro",
    "Amazona farinosa meridional"
    ),

   "Amazona_ochrocephala" = c(
    "Amazona ochrocephala",
    "Amazona de front groc",
    "Amazona frontgroga",
    "Lloro de cap groc",
    "Lloro reial",
    "Lloro de corona groga",
    "Papagai de front gorc",
    "Amazona real",
    "Loro real amazónico",
    "Loro real amazonico",
    "Amazona de cabeza amarela",
    "Papagaio-campeiro",
    "Papagaio-de-coroa-amarela",
    "Amazona buruhoria",
    "Amazona de frente mariella",
    "Amazona frente mariella",
    "Amazona frente amarilla"
    ),

   "Amazonetta_brasiliensis" = c(
    "Amazonetta brasiliensis",
    "Pato brasileño",
    "Ànec del Brasil",
    "Marreca-de-pé-vermelho",
    "Marrequinha-brasileira",
    "Ahate brasildar",
    "Ahate brasildarra",
    "Pato Brasileiro"
    ),

   "Aratinga_leucophthalma" = c(
    "Aratinga leucophthalma",
    "Psittacara leucophthalmus",
    "Aratinga ojiblanca",
    "Cotorra ojiblanca",
    "Aratinga ullblanca",
    "Aratinga d'ulls blancs",
    "Periquitão-d'olho-branco"
    ),

   "Atheta_mucronata" = c(
    "Atheta mucronata"
    ),

   "Bemisia_tabaci" = c(
    "Bemisia tabaci",
    "Aleyrodes tabaci",
    "Mosca blanca",
    "Mosca blanca del tabaco",
    "Mosquita blanca del tabaco",
    "Mosca blanca del algodonero",
    "Mosca-branca",
    "Mosca blanca del tabacu",
    "Mosca-branca-do-tabaco",
    "Mosca blanca del tabac",
    "Mosca-branca da batata-doce"
    ),

   "Bursaphelenchus_xylophilus" = c(
    "Bursaphelenchus xylophilus",
    "Nematodo de la madera del pino",
    "Nematode de la fusta del pi",
    "Nematodo-da-madeira-do-pinheiro",
    "Pinuen nematodoaren gaitza",
    "Nematodo da madeira de piñeiro",
    "Nematodo de la madera de los pinos"
    ),

   "Ceratitis_capitata" = c(
    "Ceratitis capitata",
    "Mosca del Mediterráneo",
    "Mosca mediterránea de la fruta",
    "Mosca del Mediterraneo",
    "Mosca mediterranea de la fruta",
    "Mosca frutera del Mediterráneo",
    "Mosca frutera del Mediterraneo",
    "Mosca-das-frutas do mediterrâneo",
    "Mosca-das-frutas do mediterraneo",
    "Mosca-da-fruta do Mediterrâneo",
    "Mosca-da-fruta do Mediterraneo",
    "Mosca da froita mediterránea",
    "Mosca da froita mediterranea",
    "Mosca-do-mediterrâneo",
    "Mosca-do-mediterraneo",
    "Mosca rajada",
    "Mosca mediterrânica da fruta",
    "Mosca mediterranica da fruta",
    "Mosca mediterrània de la fruita",
    "Mosca mediterrania de la fruita",
    "Mosca mediterrânica de la fruita",
    "Mosca mediterranica de la fruita",
    "Mosca del Mediterrani"
    ),

   "Diadema_antillarum" = c(
    "Diadema antillarum",
    "Erizo de lima",
    "Erizo de mar negro",
    "Erizo de mar de espinas largas",
    "Ourizo de mar de espiñas longas",
    "Ouriço de espinhos longos",
    "Ouriço do mar de espinho longo",
    "Ouriço-do-mar de espinhos longos",
    "Eriçó de mar d'espines llargues",
    "Eriçó Diadema"
    ),

   "Drepanaphis_acerifoliae" = c(
    "Drepanaphis acerifoliae"
    ),

   "Drosophila_suzukii" = c(
    "Drosophila suzukii",
    "Drosófila de alas manchadas",
    "Drosófila de ala manchada",
    "Drosofila de alas manchadas",
    "Drosofila de ala manchada",
    "Mosca del vinagre de alas manchadas",
    "Mosca del vinagre alas manchadas",
    "Mosca-do-vinagre-de-asa-manchada",
    "Drosófila das asas manchadas",
    "Drosofila das asas manchadas",
    "Mosca d’ales tacades"
    ),

   "Eos_squamata" = c(
    "Eos squamata",
    "Lori ventrenegre",
    "Lori collar violeta",
    "Lori escamoso",
    "Lóris de colar violeta",
    "Loris de colar violeta",
    "Lóri-de-pescoço-violeta",
    "Lori-de-pescoço-violeta",
    "Lori de collar violeta",
    "Lori de collaret violeta"
    ),

   "Euplectes_macroura" = c(
    "Euplectes macroura",
    "Obispo dorsiamarillo",
    "Bisbe de dors groc",
    "Teixidor d'espatlles grogues",
    "Bispo-de-dorso-amarelo",
    "Viúva-de-manto-amarelo",
    "Bispo-de-manto-amarelo",
    "Bisbe dorsigroc",
    "Euplekte sorbaldahori",
    "Euplekte sorbaldahoria"
    ),

   "Paratrechina_vividula" = c(
    "Paratrechina vividula"
    ),

   "Pionites_melanocephalus" = c(
    "Pionites melanocephalus",
    "Caique de cabeza negra",
    "Cherlicres",
    "Lloro capnegre",
    "Caique de cap negre",
    "Lorito chirlecrés",
    "Marianinha de cabeça preta",
    "Papagaio-de-barrete-preto"
    ),

   "Poicephalus_crassus" = c(
    "Poicephalus crassus",
    "Lloro niam niam",
    "Lloro niam-niam",
    "Lloro nyam-nyam",
    "Lorito nianiam",
    "Papagaio de niam-niam"
    ),

   "Primolius_maracana" = c(
    "Primolius maracana",
    "Guacamayo maracaná",
    "Guacamayo maracana",
    "Guacamayo de Illiger",
    "Guacamayo de cara afeitada",
    "Guacamayo cara afeitada",
    "Guacamai alablau",
    "Arara d'asa azul",
    "Maracanã-verdadeiro",
    "Arara de Illiger"
    ),

   "Scyphophorus_acupunctatus" = c(
    "Scyphophorus acupunctatus",
    "Picudo del agave",
    "Gorgojo del agave",
    "Picudo negro del agave",
    "Morrut negre",
    "Morrut de l’atzavara",
    "Morrut de les atzavares",
    "Morrut de atzavares",
    "Escaravelho-do-Agave",
    "Gorgulho de agave",
    "Gorgojo do agave"
    ),

   "Thaumastocoris_peregrinus" = c(
    "Thaumastocoris peregrinus",
    "Chinche del eucalipto",
    "Xinxa de l'eucaliptus",
    "Percevejo-do-bronzeamento",
    "Percevejo-bronzeado-do-eucalipto",
    "Percevejo-bronzeado"
    ),

   "Rugulopteryx_okamurae" = c(
    "Rugulopteryx okamurae",
    "Alga asiática",
    "Algas asiáticas",
    "Alga asiatica",
    "Algas asiaticas",
    "Alga invasora asiática",
    "Alga asiática invasora",
    "Alga asiatica invasora"
    ),

   "Halimeda_incrassata" = c(
    "Halimeda incrassata"
    ),

   "Aplidium_accarens" = c(
    "Aplidium accarense"
    ),

   "Epichrysocharis_burwelli" = c(
    "Epichrysocharis burwelli"
    ),

   "Ophelimus_maskelli" = c(
    "Ophelimus maskelli"
    ),

   "Tenellia_adspersa" = c(
    "Tenellia adspersa"
    ),

   "Chrysonephos_lewisii" = c(
    "Chrysonephos lewisii"
    ),

   "Crassula_helmsii" = c(
    "Crassula helmsii",
    "Crásula de agua",
    "Crasula de agua",
    "Crásula acuática",
    "Crásula acuatica",
    "Crasula acuática",
    "Crasula acuatica"
    ),

   "Molgula_manhattensis" = c(
    "Molgula manhattensis",
    "Raïm de (la) mar",
    "Raïm de mar",
    "Raïm marí",
    "Raïm mari"
    ),

   "Paracerceis_sculpta" = c(
    "Paracerceis sculpta",
    "Isópodo esculpido",
    "Isopodo esculpido"
    ),

   "Amathia_verticillata" = c(
    "Amathia verticillata",
    "Briozoo espagueti",
    "Espaguete bryozoo"
    ),

   "Ficopomatus_enigmaticus" = c(
     "Ficopomatus enigmaticus",
     "Poliqueto constructor de arrecifes calcáreos",
     "Poliqueto constructor de arrecifes calcareos",
     "Gusano formador de arrecifes"
    ),

   "Caprella_mutica" = c(
     "Caprella mutica",
     "Camarón esqueleto japonés",
     "Camarón esquelet japonès",
     "Camarón esqueleto xaponés",
     "Camarón esqueleto japones",
     "Camarón esquelet japones",
     "Camarón esqueleto xapones",
     "Camaron esqueleto japonés",
     "Camaron esquelet japonès",
     "Camaron esqueleto xaponés",
     "Camaron esqueleto japones",
     "Camaron esquelet japones",
     "Camaron esqueleto xapones",
     "Camarão esqueleto japonês",
     "Camarão esqueleto japones"
    ),

   "Maize_chlorotic_mottle_virus" = c(
     "Maize chlorotic mottle virus",
     "Virus del moteado clorótico del maíz",
     "Vírus do Mosqueado Clorótico do Milho",
     "Vírus da mancha clorótica do milho",
     "Virus del moteado clorotico del maíz",
     "Vírus do Mosqueado Clorotico do Milho",
     "Vírus da mancha clorotica do milho",
     "Virus del moteado clorótico del maiz",
     "Virus del moteado clorotico del maíz",
     "Virus del moteado clorotico del maiz"
    ),

   "Sweet_potato_virus_C" = c(
     "Sweet potato virus C",
     "Virus C de la batata",
     "Vírus da batata doce C",
     "Vírus C da batata-doce",
     "Vírus C da batata-doce",
     "Vírus da batata-doce"
    ),

   "Synoicus_chinensis" = c(
     "Synoicus chinensis",
     "Codorniz china",
     "Guatlla blava asiàtica",
     "Guatlla blava asiatica",
     "Codorniz chinesa"
    ),

   "Tomato_leaf_curl_New_Delhi_virus" = c(
     "Tomato leaf curl New Delhi virus",
     "Virus del rizado amarillo del tomate de Nueva Delhi",
     "Virus del rizado de la hoja del tomate de Nueva Delhi",
     "Virus del enrollado amarillo del tomate de Nueva Delhi",
     "Virus del rizado del tomate de Nueva Delhi",
     "Virus de Nueva Delhi",
     "Virus de l'arrissat del tomàquet de Nova Delhi",
     "Virus de l'arrissat groc del tomàquet de Nova Delhi",
     "Virus de Nova Delhi",
     "Vírus de onda amarela do tomate de Nova Delhi",
     "Vírus enrolado da folha do tomate Nova Delhi",
     "ToLCNDV"
    ),

   "Tomato_mottle_mosaic_virus" = c(
     "Tomato mottle mosaic virus",
     "Virus del mosaico moteado del tomate",
     "Virus del mosaico del moteado",
     "Virus del moteado leve del tomate"
    ),

   "Phytophthora_citricola" = c(
     "Phytophthora citricola",
     "Aguado en cítricos",
     "Aguado de los cítricos",
     "Aguado cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Podredumbre radicular de cítricos",
     "Podredumbre radicular de los cítricos",
     "Aguado en citricos",
     "Aguado de los citricos",
     "Aguado citricos",
     "Pudrición marrón de los citricos",
     "Podredumbre marrón de los citricos",
     "Podedumbre marrón en los citricos",
     "Podredumbre marrón en citricos",
     "Podredumbre radicular de citricos",
     "Podredumbre radicular de los citricos",
     "Pudrición marron de los cítricos",
     "Podredumbre marron de los cítricos",
     "Podedumbre marron en los cítricos",
     "Podredumbre marron en cítricos",
     "Pudrición marrón de los cítricos",
     "Podredumbre marrón de los cítricos",
     "Podedumbre marrón en los cítricos",
     "Podredumbre marrón en cítricos",
     "Aigualit dels cítrics"
    ),

   "Rapana_venosa" = c(
     "Rapana venosa",
     "Busano veteado",
     "Buche de rapa",
     "Caracol venoso"
    ),

   "Tritia_mutabilis" = c(
     "Tritia mutabilis",
     "Mugarida lisa",
     "Cornet d’arenal",
     "Margarida llisa",
     "Cargolí Blanc",
     "Cargolí Margarida",
     "Cargoli Blanc",
     "Cargoli Margarida"
    ),

   "Harmonia_axyridis" = c(
     "Harmonia axyridis",
     "Mariquita asiática multicolor",
     "Mariquita asiática",
     "Mariquita arlequín",
     "Marieta asiàtica multicolor",
     "Marieta asiàtica",
     "Marieta arlequí",
     "Xoaniña asiática multicor",
     "Xoaniña asiática",
     "Xoaniña da China",
     "Xoaniña arlequín",
     "Arlekin marigorringoa",
     "Joaninha asiática multicolorida",
     "Joaninha asiática",
     "Mariquita asiatica multicolor",
     "Mariquita asiatica",
     "Mariquita arlequin",
     "Marieta asiatica multicolor",
     "Marieta asiatica",
     "Marieta arlequi",
     "Xoaniña asiatica multicor",
     "Xoaniña asiatica",
     "Xoaniña asiatica",
     "Xoaniña da China",
     "Xoaniña arlequin",
     "Joaninha asiatica multicolorida",
     "Joaninha asiatica",
     "Joaninha arlequim"
    ),

   "Psephotus_haematonotus" = c(
     "Psephotus haematonotus",
     "Rabadilla roja",
     "Periquito de rabadilla roja",
     "Periquito rabadilla roja",
     "Perico dorsirrojo",
     "Perico de rabadilla roja",
     "Perico rabadilla roja",
     "Periquito dorsirrojo",
     "Cotorra de carpó roig",
     "Cotorra de carpo roig",
     "Cotorra de dors roig",
     "Perico carpó-roig",
     "Perico carpo-roig",
     "Periquito-d'uropígio-vermelho"
    ),

   "Pycnonotus_jocosus" = c(
     "Pycnonotus jocosus",
     "Bulbul orfeo",
     "Bulbul de bigoti vermell",
     "Bulbul orfeu",
     "Bulbul de bigot roig",
     "Bulbul de faceiras vermellas",
     "Bulbul de meixelas brancas",
     "Bulbul masailgorri",
     "Bulbul moñuzu",
     "Bulbul-de-faces-vermelhas"
    ),

   "Axonopus_fissifolius" = c(
     "Axonopus fissifolius",
     "Hierba de alfombra común",
     "Hierba de alfombra comun",
     "Grama brasilera"
    ),

   "Pyura_herdmani" = c(
     "Pyura herdmani",
     "Cebo rojo africano"
    ),

   "Cydalima_perspectalis" = c(
     "Cydalima perspectalis",
     "Polilla del boj",
     "Piral del boj",
     "Eruga del boix",
     "Eruga defoliadora del boix",
     "Papallona del boix",
     "Palometa del boix",
     "Avelaíña do buxo",
     "Ezpel sits",
     "Ezpel sitsa"
    ),

   "Megachile_sculpturalis" = c(
     "Megachile sculpturalis",
     "Abeja gigante de la resina",
     "Abeja invasora escultórica",
     "Abeja invasora escultorica",
     "Abella gegant de la resina",
     "Abella xigante de resina"
    ),

   "Wasmannia_auropunctata" = c(
     "Wasmannia auropunctata",
     "Hormiga eléctrica",
     "Hormiga electrica",
     "Hormiguita de fuego",
     "Pequeña hormiga de fuego",
     "Hormiga pequeña de fuego",
     "Formiga de foc roja",
     "Formigueta de foc",
     "Petita formiga de foc",
     "Formiga petita de foc",
     "Formiguiña de lume",
     "Formiga electrica",
     "Formiga elèctrica"
    ),

   "Mauremys_reevesii" = c(
     "Mauremys reevesii",
     "Tortuga china de estanque",
     "Tortuga de estanque china",
     "Tortuga china de tres crestas",
     "Tortuga china crestada",
     "Tortuga crestada china",
     "Tortuga de tres crestas",
     "Galápago chino de tres crestas",
     "Galapago chino de tres crestas",
     "Tortuga d'estany xinesa",
     "Tortuga d'aigua xinesa",
     "Tortuga xinesa de tres quilles",
     "Sapoconcho chinés de tres quillas",
     "Sapoconcho chines de tres quillas",
     "Sapoconcho de tres quillas",
     "Tartaruga-chinesa-de-tres-quillas",
     "Tartaruga de estanque chinesa",
     "Tartaruga chinesa de três quilhas"
    ),

   "Mauremys_sinensis" = c(
     "Mauremys sinensis",
     "Galápago chino de cuello estriado",
     "Tortuga de cuello rayado",
     "Tortuga china de cuello rayado",
     "Tortuga china cuello rayado",
     "Tortuga cuello rayado china",
     "Tortuga cuello rayado",
     "Tortuga de cuello rallado",
     "Tortuga china de cuello rallado",
     "Tortuga de cuello estriado",
     "Tortuga de cuello con franjas",
     "Tortuga Ocadia",
     "Tortuga de coll ratllat",
     "Tortuga xinesa de coll ratllat",
     "Sapoconcho de pescozo listado",
     "Tartaruga de pescozo con franxas",
     "Tartaruga-chinesa-de-pescoço-listado",
     "Tartaruga chinesa de pescoço listrado",
     "Tartaruga-de-pescoço-listrado-chinesa",
     "Tartaruga chinesa de pescoço às riscas"
    ),

   "Ludwigia_peploides" = c(
     "Ludwigia peploides",
     "Duraznillo de agua",
     "Onagraria",
     "Enramada de las tarariras"
    ),

   "Pseudemys_peninsularis" = c(
     "Pseudemys peninsularis",
     "Tortuga de la península",
     "Galápago peninsular",
     "Tortuga de la peninsula",
     "Galapago peninsular"
    ),

   "Spodoptera_frugiperda" = c(
     "Spodoptera frugiperda",
     "Gusano cogollero",
     "Cogollero del maíz",
     "Gusano cogollero del maíz",
     "Oruga cogollera del maíz",
     "Oruga militar tardía",
     "Cogollero del maiz",
     "Gusano cogollero del maiz",
     "Oruga cogollera del maiz",
     "Oruga militar tardia",
     "Cuc cogoller",
     "Oruga militar tardana",
     "Verme-cogollero-do-millo",
     "Lagarta-do-cartucho"
    ),

   "Halyomorpha_halys" = c(
     "Halyomorpha halys",
     "Chinche parda marmorada",
     "Chinche hedionda marrón marmoleada",
     "Chinche apestosa marrón marmolada",
     "Chinche apestoso marrón mármol",
     "Chinche apestoso marron mármol",
     "Chinche apestosa marrón",
     "Chinche apestoso marrón",
     "Chinche hedionda marron marmoleada",
     "Chinche apestosa marron marmolada",
     "Chinche apestoso marron mármol",
     "Chinche apestoso marron marmol",
     "Chinche apestosa marron",
     "Chinche apestoso marron",
     "Chinche apestosa",
     "Chinche hedionda",
     "Bernat marbrejat",
     "Bernat marbrat marró",
     "Bernat marbrat marro",
     "Armarri zimitz jaspeztatua",
     "Zimitz kirasdun marroia",
     "Percevejo marrom marmoreado",
     "Percevejo-asiático",
     "Percevejo-asiatico",
     "Percevejo-fedorento marrom marmorizado"
    ),

   "Aedes_aegypti" = c(
     "Aedes aegypti",
     "Mosquito del dengue",
     "Mosquito momia",
     "Mosquito de la fiebre amarilla",
     "Mosquito africano de la fiebre amarilla",
     "Mosquit del dengue",
     "Mosquit de la febre groga",
     "Mosquito da dengue",
     "Sukar horiaren eltxoak",
     "Mosquito da dengue",
     "Pernilongo rajado"
    ),

   "Euwallacea_fornicatus" = c(
     "Euwallacea fornicatus",
     "Barrenador polígafo",
     "Barrenillo del té",
     "Escarabajo barrenillo del té",
     "Escarabajo barrenador polígafo",
     "Broca-de-tiro-do-chá",
     "Broca-de-tiro-polífaga",
     "Barrenador poligafo",
     "Barrenillo del te",
     "Escarabajo barrenillo del te",
     "Escarabajo barrenador poligafo",
     "Broca-de-tiro-do-cha",
     "Broca-de-tiro-polifaga"
    ),

   "Procambarus_virginalis" = c(
     "Procambarus virginalis",
     "Cangrejo mármol",
     "Cangrejo de mármol",
     "Cangrejo marmol",
     "Cangrejo de marmol",
     "Cangrejo marmoleado",
     "Marmorkrebs"
    ),

   "Cherax_quadricarinatus" = c(
     "Cherax quadricarinatus",
     "Langosta australiana azul",
     "Langosta de agua dulce",
     "Langosta de agua dulce australiana",
     "Langosta de agua dulce de pinzas rojas",
     "Langosta azul",
     "Langosta de río australiana",
     "Langosta de rio australiana",
     "Langosta azul australiana",
     "Yabby azul",
     "Llagosta blava",
     "Llagosta blava australiana",
     "Llagosta autraliana d'aigua dolça",
     "Llagosta d'aigua dolça australiana",
     "Lagosta azul australiana",
     "Lagosta de água doce",
     "Lagosta de água doce australiana",
     "Lagosta de agua doce",
     "Lagosta de agua doce australiana"
    ),

   "Xylella_fastidiosa" = c(
     "Xylella fastidiosa",
     "Xilel la",
     "Xilel·la"
    ),

   "Tobamovirus_fructirugosum" = c(
     "Tobamovirus fructirugosum",
     "Virus del fruto rugoso marrón del tomate",
     "Virus del fruto rugoso marron del tomate",
     "Virus rugoso del tomate",
     "Virus del fruto pardo y rugoso del tomate"
    )

)


# Assuming your list is named all_lists_NEW_ES_PT_regioncode_scientific_common

# Extract names and replace underscores with spaces
species_names <- names(all_lists_NEW_ES_PT_regioncode_scientific_common)
species_names_clean <- gsub("_", " ", species_names)

# View the cleaned species names
print(species_names_clean)

# Optionally, save as a data frame
species_df <- data.frame(Species = species_names_clean)

# If you want to export to CSV
# write.csv(species_df, "species_searched.csv", row.names = FALSE)


########################################################################### PREPARE THE DATASET (MATCHES OF SEARCH TERMS WITH ALL SP NAMES ##################################################################

library(data.table)
library(stringi) # For text normalization

# Function to normalize text (remove accents and convert to lowercase)
normalize_text <- function(text) {
  stri_trans_general(stri_trim(text), "Latin-ASCII") # Convert accents to ASCII equivalent
}

# Convert dataset to data.table if not already
setDT(final_region_scientific_common_dedup)


# === Step 1: Create Lookup Table from `all_lists_NEW_ES_PT_regioncode_scientific_common` ===
lookup_table <- data.table(
  NEW_ES_PT_regioncode_scientific_common_name = unlist(all_lists_NEW_ES_PT_regioncode_scientific_common, use.names = FALSE),
  unique_species = rep(names(all_lists_NEW_ES_PT_regioncode_scientific_common), times = sapply(all_lists_NEW_ES_PT_regioncode_scientific_common, length))
)

# Normalize text in lookup table
lookup_table[, NEW_ES_PT_regioncode_scientific_common_name := normalize_text(NEW_ES_PT_regioncode_scientific_common_name)]

# Remove duplicates to avoid multiple mappings
lookup_table <- unique(lookup_table, by = "NEW_ES_PT_regioncode_scientific_common_name")

# === Step 2: Normalize Species Names in the Main Dataset ===
final_region_scientific_common_dedup[, species_normalized := normalize_text(query)]

# Ensure both columns are characters (avoiding potential factor issues)
lookup_table[, NEW_ES_PT_regioncode_scientific_common_name := as.character(NEW_ES_PT_regioncode_scientific_common_name)]
final_region_scientific_common_dedup[, species_normalized := as.character(species_normalized)]


# === Step 3: Perform the Merge ===
final_region_scientific_common_dedup <- merge(
  final_region_scientific_common_dedup,
  lookup_table,
  by.x = "species_normalized",
  by.y = "NEW_ES_PT_regioncode_scientific_common_name",
  all.x = TRUE,
  allow.cartesian = TRUE
)


unique(final_region_scientific_common_dedup$unique_species)

  [1] "Megachile_sculpturalis"                   "Phoeniculus_purpureus"                    "Zebrasoma_flavescens"                     "Acizzia_jamatonica"
  [5] "Acridotheres_cristatellus"                "Acridotheres_ginginianus"                 "Aedes_aegypti"                            "Aedes_japonicus"
  [9] "Agapornis_fischeri"                       "Agapornis_nigrigenis"                     "Phytophthora_citricola"                   "Geranoaetus_melanoleucus"
 [13] "Haliaeetus_leucocephalus"                 "Rugulopteryx_okamurae"                    "Amathia_verticillata"                     "Amazona_albifrons"
 [17] "Amazona_amazonica"                        "Amazona_farinosa"                         "Amazona_ochrocephala"                     "Amazonetta_brasiliensis"
 [21] "Anas_flavirostris"                        "Anoplolepis_gracilipes"                   "Anser_cygnoides"                          "Grus_canadensis"
 [25] "Apalone_ferox"                            "Aratinga_jandaya"                         "Aratinga_leucophthalma"                   "Eupsittula_pertinax"
 [29] "Leuciscus_aspius"                         "Vanellus senegallus"                      "Vespa_velutina"                           "Dryocosmus_kuriphilus"
 [33] "Vespa_orientalis"                         "Vespa_soror"                              "Axonopus_fissifolius"                     "Ictalurus_punctatus"
 [37] "Megabalanus_tintinnabulum"                "Balistoides_conspicillum"                 "Platycerium_bifurcatum"                   "Barbronia_weberi"
 [41] "Branta_canadensis"                        "Belonochilus_numenius"                    "Bemisia_tabaci"                           "Halyomorpha_halys"
 [45] "Blechnum_occidentale"                     "Brachymyrmex_patagonicus"                 "Pycnonotus_jocosus"                       "Bursaphelenchus_xylophilus"
 [49] "Geranoaetus_polyosoma"                    "Bycanistes_brevis"                        "Pionites_melanocephalus"                  "Tockus_deckeni"
 [53] "Caloenas_nicobarica"                      "Rhodospiza_obsoleta"                      "Haemorhous_mexicanus"                     "Camponotus_compressus"
 [57] "Procambarus_virginalis"                   "Caprella_mutica"                          "Caprella_scaura"                          "Lonchura_oryzivora"
 [61] "Caracara_plancus"                         "Pomacea_maculata"                         "Rapana_venosa"                            "Carassius_gibelio"
 [65] "Cardiocondyla_obscurior"                  "Chloephaga_picta"                         "Ceratitis_capitata"                       "Sus_scrofa_var_domestica_raza_vietnamita"
 [69] "Cereopsis_novaehollandiae"                "Chenonetta_jubata"                        "Cherax_quadricarinatus"                   "Leptoglossus_occidentalis"
 [73] "Thaumastocoris_peregrinus"                "Chrysonephos_lewisii"                     "Pluchea_carolinensis"                     "Cygnus_melancoryphus"
 [77] "Synoicus_chinensis"                       "Spodoptera_frugiperda"                    "Platalea_ajaja"                           "Columbina_talpacoti"
 [81] "Glycaspis_brimblecombei"                  "Corvus_albus"                             "Delottococcus_aberiae"                    "Crangonyx_pseudogracilis"
 [85] "Crassula_helmsii"                         "Mnemiopsis_leidyi"                        "Reticulitermes_flavipes"                  "Cydalima_perspectalis"
 [89] "Diadema_antillarum"                       "Drosophila_suzukii"                       "Ludwigia_peploides"                       "Duttaphrynus_melanostictus"
 [93] "Dyspanopeus_sayi"                         "Elanoides_forficatus"                     "Graptemys_pseudogeographica"              "Ensis_leei"
 [97] "Eos_squamata"                             "Equisetum_palustre"                       "Euwallacea_fornicatus"                    "Faxonius_limosus"
[101] "Ficopomatus_enigmaticus"                  "Paratrechina_jaegerskioeldi"              "Tapinoma_melanocephalum"                  "Scyphophorus_acupunctatus"
[105] "Primolius_maracana"                       "Phthorimaea_absoluta"                     "Halimeda_incrassata"                      "Harmonia_axyridis"
[109] "Planorbella_duryi"                        "Wasmannia_auropunctata"                   "Pheidole_megacephala"                     "Hydrocharis_laevigata"
[113] "Hypoponera_ergatandria"                   "Lagocephalus_sceleratus"                  "Lasius_neglectus"                         "Lepisiota_capensis"
[117] "Psittacus_erithacus"                      "Macrohomotoma_gladiata"                   "Primolius_auricollis"                     "Mauremys_reevesii"
[121] "Mauremys_sinensis"                        "Molgula_manhattensis"                     "Varanus_exanthematicus"                   "Neophema_pulchella"
[125] "Neotoxoptera_formosana"                   "Ommatotriton_ophryticus"                  "Ophelimus_maskelli"                       "Palaemon_macrodactylus"
[129] "Zenaida_meloda"                           "Paracerceis_sculpta"                      "Paracoccus_burnerae"                      "Styela_plicata"
[133] "Pelodiscus_sinensis"                      "Perca_fluviatilis"                        "Psephotus_haematonotus"                   "Pheidole_indica"
[137] "Poicephalus_crassus"                      "Pseudemys_concinna"                       "Pseudemys_peninsularis"                   "Pseudosuccinea_columella"
[141] "Psilopsiagon_aymara"                      "Aphis_illinoisensis"                      "Sipha_flava"                              "Epitrix_similaris"
[145] "Schizoporella_errata"                     "Sophonia_orientalis"                      "Spatula_hottentota"                       "Stenopelmus_rufinasus"
[149] "Strumigenys_silvestrii"                   "Testudo_marginata"                        "Tenellia_adspersa"                        "Tomato_leaf_curl_New_Delhi_virus"
[153] "Trachemys_emolli"                         "Trachymela_sloanei"                       "Tritia_mutabilis"                         "Vespa_bicolor"
[157] "Tobamovirus_fructirugosum"                "Xylella_fastidiosa"                       "Xylotrechus_chinensis"


# Ensure your dataset is a data.table
setDT(final_region_scientific_common_dedup)

# Count number of rows (videos) per unique_species
species_counts_NEW_ES_PT_regioncode_scientific_common <- final_region_scientific_common_dedup[, .N, by = unique_species][order(-N)]

# View top species by video count
print(species_counts_NEW_ES_PT_regioncode_scientific_common)

    unique_species     N
                       <char> <int>
  1:           Vespa_velutina   691
  2:      Psittacus_erithacus   688
  3: Geranoaetus_melanoleucus   482
  4: Haliaeetus_leucocephalus   430
  5:    Spodoptera_frugiperda   403
 ---
155:       Ophelimus_maskelli     1
156:      Paracoccus_burnerae     1
157:     Schizoporella_errata     1
158:      Sophonia_orientalis     1
159:    Stenopelmus_rufinasus     1


--------------################ DATASET WITH SPECIES WITH 0 SEARCH RESULTS ###############

# ? All species you searched for (from your lookup list)
all_species_NEW_ES_PT_regioncode_scientific_common <- names(all_lists_NEW_ES_PT_regioncode_scientific_common)

# ? Species actually matched in the YouTube results
included_species_NEW_ES_PT_regioncode_scientific_common <- unique(final_region_scientific_common_dedup$unique_species)

# ? Find species that were NOT included (i.e., no search results)
missing_species_NEW_ES_PT_regioncode_scientific_common <- setdiff(all_species_NEW_ES_PT_regioncode_scientific_common, included_species_NEW_ES_PT_regioncode_scientific_common)

# ? View the missing species
missing_species_NEW_ES_PT_regioncode_scientific_common

 [1] "Blastopsylla_occidentalis"    "Gobio_occitaniae"             "Lorius_chlorocercus"          "Macrochelys_temminckii"
 [5] "Maeotias_marginata"           "Marisa_cornuarietis"          "Microlepia_platyphylla"       "Mimus_gilvus"
 [9] "Musophaga_violacea"           "Netta_peposaca"               "Obolodiplosis_robiniae"       "Orientogalba viridis"
[13] "Psyllaephagus_bliteus"        "Puto_barberi"                 "Epidiplosis_filifera"         "Penthimiola_bella"
[17] "Stenothoe_georgiana"          "Hercinothrips_dimidiatus"     "Bosmina_coregoni"             "Lobiopa_insularis"
[21] "Chrysonotomyia_chamaeleon"    "Pezothrips_kellyanus"         "Pseudodiaptomus_marinus"      "Hemicypris_barbadensis"
[25] "Hemicypris_reticulata"        "Brachymyrmex_heeri"           "Tapinoma_pallipes"            "Paracaprella_pusilla"
[29] "Solidobalanus_fallax"         "Theora_lubrica"               "Atriplex_semilunaris"         "Eucheilota_menoni"
[33] "Branchiomma_bairdi"           "Perinereis_linea"             "Perophora_japonica"           "Marginella_glabella"
[37] "Ferrissia_californica"        "Atheta_mucronata"             "Drepanaphis_acerifoliae"      "Euplectes_macroura"
[41] "Paratrechina_vividula"        "Aplidium_accarens"            "Epichrysocharis_burwelli"     "Maize_chlorotic_mottle_virus"
[45] "Sweet_potato_virus_C"         "Tomato_mottle_mosaic_virus"   "Pyura_herdmani"

# Vector of missing species
missing_species_NEW_ES_PT_regioncode_scientific_common <- c(
 "Barbronia_weberi",           "Blastopsylla_occidentalis",  "Chenonetta_jubata",          "Crangonyx_pseudogracilis",   "Gobio_occitaniae",
 "Equisetum_palustre",         "Maeotias_marginata",         "Trachemys_emolli",           "Lepisiota_capensis",         "Neotoxoptera_formosana",
 "Puto_barberi",               "Glycaspis_brimblecombei",    "Lasius_neglectus",           "Anoplolepis_gracilipes",    "Pseudosuccinea_columella",
 "Faxonius_limosus",           "Duttaphrynus_melanostictus", "Xylotrechus_chinensis",      "Macrohomotoma_gladiata",     "Dyspanopeus_sayi",
 "Megabalanus_tintinnabulum",  "Perophora_japonica",         "Ensis_leei",                 "Reticulitermes_flavipes",    "Acizzia_jamatonica",
 "Euplectes_macroura",         "Poicephalus_crassus",        "Vespa_bicolor"
)

# Normalize function (like before)
normalize_text <- function(text) stri_trans_general(stri_trim(text), "Latin-ASCII")

# Normalize search terms in the combined dataset
final_region_scientific_common_dedup$search_term_normalized <- normalize_text(final_region_scientific_common_dedup$search_term)

# Normalize the scientific names (remove underscores and lowercase)
normalized_missing_species_NEW_ES_PT_regioncode_scientific_common <- tolower(gsub("_", " ", missing_species_NEW_ES_PT_regioncode_scientific_common))
normalized_missing_species_NEW_ES_PT_regioncode_scientific_common <- normalize_text(normalized_missing_species_NEW_ES_PT_regioncode_scientific_common)

# Check which species DO appear in search_term
matching_species_NEW_ES_PT_regioncode_scientific_common <- unique(
  final_region_scientific_common_dedup$search_term_normalized[
    final_region_scientific_common_dedup$search_term_normalized %in% normalized_missing_species_NEW_ES_PT_regioncode_scientific_common
  ]
)

# View results
cat("? These missing species WERE found in 'final_region_scientific_common_dedup':\n")
print(matching_species_NEW_ES_PT_regioncode_scientific_common)

# Optionally, show which were truly missing
truly_missing_NEW_ES_PT_regioncode_scientific_common <- setdiff(normalized_missing_species_NEW_ES_PT_regioncode_scientific_common, matching_species_NEW_ES_PT_regioncode_scientific_common)

cat("\n? These species are completely absent (not even searched):\n")
print(truly_missing_NEW_ES_PT_regioncode_scientific_common)


# Add the "created_at" column as a copy of "published"
final_region_scientific_common_dedup <- final_region_scientific_common_dedup %>%
  mutate(created_at = publishedAt)

# Verify the new column is added and matches the "published" column
head(final_region_scientific_common_dedup[, c("publishedAt", "created_at")])


final_region_scientific_common_dedup <- as.data.table(final_region_scientific_common_dedup)
#subset_Aedes_japonicus <- youtube_recent_all_post[youtube_recent_all_post$species_name == "Aedes japonicus",]

# Get unique species names
unique_species <- unique(final_region_scientific_common_dedup$unique_species)

# Rename 'unique_species' to 'TaxonName' in final_region_scientific_common_dedup
final_region_scientific_common_dedup <- final_region_scientific_common_dedup %>%
  rename(TaxonName = unique_species)


####################################################################################### ADDING FIRST ZENODO INFORMATION TO THE FORMATTED DATASET ###########################################################

# Load required packages
library(readxl)
library(dplyr)
library(tidyr)
library(cld2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)
library(officer)


# Read the Excel file
zenodo_sp_list <- read_excel("Recent_Intros_IP_All_for_table_v31_SP_NAMES_UPDATED_cleaned_rev_loc_filters.xlsx")

# Step 1: Clean LifeForm names
zenodo_sp_list <- zenodo_sp_list %>%
  mutate(
    LifeForm = as.character(LifeForm),
    LifeForm = recode(LifeForm,
      "Invertebrates (excl. Arthropods, Molluscs)" = "Non-arthropod invertebrates"
    )
  )

# Step 2: Replace NA in PresentStatus with "uncertain"
zenodo_sp_list$PresentStatus[is.na(zenodo_sp_list$PresentStatus)] <- "uncertain"

# Step 3: Group taxa categories
zenodo_grouped <- zenodo_sp_list %>%
  mutate(
    LifeForm = case_when(
      LifeForm %in% c("Vascular plants", "Algae", "Bryozoa") ~ "Plants",
      LifeForm %in% c("Molluscs") ~ "Non-arthropod invertebrates",
      LifeForm %in% c("Amphibians", "Reptiles") ~ "Herptiles",
      LifeForm %in% c("Viruses","Fungi") ~ "Bacteria, Viruses, Fungi",
      TRUE ~ LifeForm
    )
  ) %>%
  filter(LifeForm != "Mammals")  # Remove group with only 1 species

# Step 4: Summarise unique species
summary_table <- zenodo_grouped %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(
    names_from = PresentStatus,
    values_from = n_species,
    values_fill = 0
  )

# Step 5: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% colnames(summary_table)) {
    summary_table[[col]] <- 0
  }
}

# Step 6: Add totals
summary_table <- summary_table %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 7: Add total row
total_row <- summary_table %>%
  summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = sum(percentage)
  )

summary_table_final_region_scientific_common <- bind_rows(summary_table, total_row) %>%
  arrange(desc(total_species))

# Step 8: Export to CSV
write.csv(summary_table_final_region_scientific_common, "summary_species_by_lifeform_with_total.csv", row.names = FALSE)

# Step 9: Export to Word (DOCX)
ft <- summary_table_final_region_scientific_common %>%
  flextable() %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

read_docx() %>%
  body_add_par("Summary of Species per Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(ft) %>%
  print(target = "summary_species_by_lifeform_with_total.docx")



# Define the priority order of PresentStatus
status_priority <- c("alien", "established", "casual", "uncertain")

# Convert PresentStatus to a factor with ordered levels
zenodo_cleaned <- zenodo_grouped %>%
  mutate(PresentStatus = factor(PresentStatus, levels = status_priority, ordered = TRUE))

# Apply filtering
zenodo_filtered <- zenodo_cleaned %>%
  group_by(TaxonName) %>%
  filter(FirstRecord == min(FirstRecord)) %>%   # Keep only rows with the minimum year
  slice_min(PresentStatus, with_ties = FALSE) %>% # Break ties using PresentStatus priority
  ungroup()

# View result
print(zenodo_filtered)


# 1. Fix TaxonName formatting + Region in zenodo_filtered
zenodo_filtered <- zenodo_filtered %>%
  mutate(
    TaxonName = str_replace_all(TaxonName, " ", "_"),
    Region_all = case_when(
      Region %in% c("Portugal", "Azores", "Madeira") ~ "Portugal",
      Region %in% c("Spain", "Canary Islands", "Andorra") ~ "Spain",
      TRUE ~ NA_character_
    )
  )

# 2. Detect language from combined text fields in video dataset
final_region_scientific_common_dedup <- final_region_scientific_common_dedup %>%
  mutate(
    text_combined = paste(
      ifelse(is.na(description), "", description),
      ifelse(is.na(title), "", title),
      ifelse(is.na(search_term), "", search_term)
    ),
    lang_detected = cld2::detect_language(text_combined, plain_text = TRUE),
    Region_all = case_when(
      lang_detected == "pt" ~ "Portugal",
      lang_detected %in% c("es", "ca", "gl", "eu", "ast") ~ "Spain",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-text_combined)  # drop helper column


# 3. Final merge on corrected TaxonName + Region_all
#combined_data_NEW_ES_PT_regioncode_scientific_common <- final_region_scientific_common_dedup %>%
#  left_join(zenodo_filtered, by = c("TaxonName"))

library(dplyr)
library(tidyr)
library(flextable)
library(officer)

# Step 1: Replace NA in PresentStatus with "uncertain"
zenodo_filtered$PresentStatus[is.na(zenodo_filtered$PresentStatus)] <- "uncertain"

# Step 2: Create summary table of species by LifeForm and PresentStatus
summary_table <- zenodo_filtered %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(n_species = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = n_species, values_fill = 0)

# Step 3: Ensure all columns exist
status_cols <- c("alien", "established", "uncertain", "casual")
for (col in status_cols) {
  if (!col %in% names(summary_table)) summary_table[[col]] <- 0
}

# Step 4: Add total species and % of total
summary_table <- summary_table %>%
  mutate(
    total_species = rowSums(across(all_of(status_cols))),
    percentage = round((total_species / sum(total_species)) * 100, 1),
    .after = LifeForm
  )

# Step 5: Add total row
total_row <- summary_table %>%
  dplyr::summarise(
    LifeForm = "Total",
    total_species = sum(total_species),
    alien = sum(alien),
    established = sum(established),
    uncertain = sum(uncertain),
    casual = sum(casual),
    percentage = round(sum(total_species) / sum(total_species) * 100, 1)
  )

summary_table_final_region_scientific_common <- bind_rows(summary_table, total_row) %>%
  arrange(desc(total_species))

# Step 6: Export to CSV
write.csv(summary_table_final_region_scientific_common, "summary_species_zenodo_filtered.csv", row.names = FALSE)

# Step 7: Export to Word
ft <- flextable(summary_table_final_region_scientific_common) %>%
  set_header_labels(
    LifeForm = "Taxonomic Group",
    total_species = "Total Species",
    percentage = "% of Total",
    alien = "Alien",
    established = "Established",
    uncertain = "Uncertain",
    casual = "Casual"
  ) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ LifeForm == "Total", part = "body")

# Save as Word file
doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group", style = "heading 1") %>%
  body_add_flextable(value = ft)

print(doc, target = "summary_species_zenodo_filtered.docx")



combined_data_NEW_ES_PT_regioncode_scientific_common <- merge(final_region_scientific_common_dedup, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# 4. Preview results
print(head(combined_data_NEW_ES_PT_regioncode_scientific_common, 5))


# 1. Count distinct Region values per TaxonName
region_counts <- zenodo_filtered %>%
  group_by(TaxonName) %>%
  summarise(region_count = n_distinct(Region), .groups = "drop")

# 2. Join counts back into the main data
zenodo_with_region_counts <- zenodo_filtered %>%
  left_join(region_counts, by = "TaxonName")

# 3. Split into repeated-region and single-region subsets
zenodo_repeated_regions <- zenodo_with_region_counts %>%
  filter(region_count > 1)

zenodo_single_region <- zenodo_with_region_counts %>%
  filter(region_count == 1)

# 4. Drop the helper column if desired
zenodo_repeated_regions <- zenodo_repeated_regions %>% select(-region_count)
zenodo_single_region <- zenodo_single_region %>% select(-region_count)

# 5. Preview
cat("?? TaxonNames in multiple regions:\n")
print(unique(zenodo_repeated_regions$TaxonName))

cat("\n? TaxonNames in a single region:\n")
print(unique(zenodo_single_region$TaxonName))



library(dplyr)
library(tidyr)
library(gt)
library(flextable)
library(officer)

# Step 0: Clean list of searched species (you already created this earlier)
# species_names_clean <- gsub("_", " ", names(all_lists_NEW_ES_PT_regioncode_scientific_common))

# Step 1: Add a temporary clean name column to zenodo_filtered for matching
zenodo_filtered <- zenodo_filtered %>%
  mutate(CleanName = gsub("_", " ", TaxonName))

# Step 2: Filter to only searched species using cleaned names
searched_zenodo <- zenodo_filtered %>%
  filter(CleanName %in% species_names_clean)

# Step 3: Combine found species (videos) with full metadata
combined_data_NEW_ES_PT_regioncode_scientific_common <- merge(final_region_scientific_common_dedup, zenodo_filtered, by = "TaxonName", all.x = TRUE)

# Step 4: Remove "Mammals" group (1 case only in found)
combined_data_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common %>% filter(LifeForm != "Mammals")
searched_zenodo <- searched_zenodo %>% filter(LifeForm != "Mammals")
zenodo_filtered <- zenodo_filtered %>% filter(LifeForm != "Mammals")

# ? Step 5: Compute total species per LifeForm from the full Zenodo dataset
total_species_summary <- zenodo_filtered %>%
  group_by(LifeForm) %>%
  summarise(total_species = n_distinct(TaxonName), .groups = "drop")

# Step 6: Compute searched species per LifeForm (subset of total)
searched_summary <- searched_zenodo %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(searched = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = searched, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_searched") %>%
  mutate(searched_species = rowSums(across(ends_with("_searched"))),
         pct_searched = round((searched_species / sum(searched_species)) * 100, 1))

# Step 7: Compute found species per LifeForm from combined dataset
found_summary <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  group_by(LifeForm, PresentStatus) %>%
  summarise(found = n_distinct(TaxonName), .groups = "drop") %>%
  pivot_wider(names_from = PresentStatus, values_from = found, values_fill = 0,
              names_glue = "{tolower(PresentStatus)}_found") %>%
  mutate(species_found = rowSums(across(ends_with("_found"))),
         pct_found = round((species_found / sum(species_found)) * 100, 1))

# Step 8: Join summaries
final_table <- searched_summary %>%
  full_join(found_summary, by = "LifeForm") %>%
  full_join(total_species_summary, by = "LifeForm") %>%
  mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>%
  mutate(
    Alien = paste0(alien_found, "/", alien_searched),
    Established = paste0(established_found, "/", established_searched),
    Uncertain = paste0(uncertain_found, "/", uncertain_searched),
    Casual = paste0(casual_found, "/", casual_searched),
    `% Found / Searched` = paste0(pct_found, "/", pct_searched),
    `% Found of Searched` = paste0(round((species_found / searched_species) * 100, 1), "%")
  ) %>%
  dplyr::select(
    `Taxonomic Group` = LifeForm,
    `Total Species` = total_species,
    `Searched Species` = searched_species,
    `Species Found` = species_found,
    `% Found of Searched`,
    `% Found / Searched`,
    Alien, Established, Uncertain, Casual
  )

# Step 9: Add total row
total_row <- final_table %>%
  summarise(
    `Taxonomic Group` = "Total",
    `Total Species` = sum(`Total Species`),
    `Searched Species` = sum(`Searched Species`),
    `Species Found` = sum(`Species Found`),
    `% Found of Searched` = paste0(round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "%"),
    `% Found / Searched` = paste0(
      round(sum(`Species Found`) / sum(`Searched Species`) * 100, 1), "/100"
    ),
    Alien = paste0(sum(as.integer(sub("/.*", "", Alien))), "/", sum(as.integer(sub(".*/", "", Alien)))),
    Established = paste0(sum(as.integer(sub("/.*", "", Established))), "/", sum(as.integer(sub(".*/", "", Established)))),
    Uncertain = paste0(sum(as.integer(sub("/.*", "", Uncertain))), "/", sum(as.integer(sub(".*/", "", Uncertain)))),
    Casual = paste0(sum(as.integer(sub("/.*", "", Casual))), "/", sum(as.integer(sub(".*/", "", Casual))))
  )

# Step 10: Bind total row to final table
final_table <- bind_rows(final_table, total_row)

# Step 11: Export to Word
ft <- flextable(final_table) %>%
  autofit() %>%
  bold(part = "header") %>%
  theme_booktabs() %>%
  bold(i = ~ `Taxonomic Group` == "Total", part = "body")

doc <- read_docx() %>%
  body_add_par("Summary of Species by Taxonomic Group (Found vs Searched)", style = "heading 1") %>%
  body_add_flextable(ft)

print(doc, target = "summary_species_combined_found_vs_searched.docx")

# Step 12: Export to CSV
write.csv(final_table, "summary_species_combined_found_vs_searched.csv", row.names = FALSE)



# 1. Find which TaxonName values are scientific_common
scientific_common_taxa <- intersect(
  unique(zenodo_single_region$TaxonName),
  unique(final_region_scientific_common_dedup$TaxonName)
)

# 2. Subset the video dataset for these scientific_common TaxonNames
#videos_single_region <- final_region_scientific_common_dedup %>%
#  filter(TaxonName %in% scientific_common_taxa)

# 3. Merge matched video data with zenodo_single_region
#combined_single_region <- videos_single_region %>%
#    left_join(zenodo_single_region, by = "TaxonName")

# 4. Optional: Remove unmatched rows after merge (those where LifeForm or Region is still NA)
#combined_single_region_clean <- combined_single_region %>%
#  filter(!is.na(LifeForm))

# 5. Now get the remaining (unmatched) videos for later merge with repeated-region species
#videos_remaining <- final_region_scientific_common_dedup %>%
#  filter(!(TaxonName %in% scientific_common_taxa))

# 6. Preview results
#cat("? Combined single-region species dataset:\n")
#print(head(combined_single_region, 3))

#cat("\n?? Remaining videos to combine with repeated-region species:\n")
#print(head(videos_remaining, 3))


############################################################################ FILTERING OUT UNRELATED YT CHANNELS ############################################################################################

channels_to_remove <- c("Andrea Espadas", "Guías Pal Esp", "Daniel Mendes", "Quadros Brasi", "AVIRUKÁ", "LA VIEJOTECA DE FERCHO", "IlloJuan")

combined_data_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  filter(!(channelTitle %in% channels_to_remove))

# Optional: Preview removed rows if needed
removed_rows <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  filter(channelTitle %in% channels_to_remove)

cat("?? Rows removed:\n")
print(unique(removed_rows$channelTitle))

cat("\n? Final dataset dimensions:\n")
print(dim(combined_data_NEW_ES_PT_regioncode_scientific_common))


# Ensure your dataset is a data.table
setDT(combined_data_NEW_ES_PT_regioncode_scientific_common)

# Count number of rows (videos) per TaxonName
species_counts_combined_data_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common[, .N, by = TaxonName][order(-N)]

# View top species by video count
print(head(species_counts_combined_data_NEW_ES_PT_regioncode_scientific_common,30))

                  TaxonName     N
                      <char> <int>
 1:           Vespa_velutina   690
 2:      Psittacus_erithacus   688
 3: Geranoaetus_melanoleucus   482
 4: Haliaeetus_leucocephalus   429
 5:    Spodoptera_frugiperda   403
 6:            Aedes_aegypti   400
 7:   Platycerium_bifurcatum   398
 8:          Anser_cygnoides   396
 9:       Lonchura_oryzivora   378
10:           Bemisia_tabaci   346
11:     Haemorhous_mexicanus   342
12:   Varanus_exanthematicus   338
13:   Cherax_quadricarinatus   332
14:           Platalea_ajaja   277
15:       Ceratitis_capitata   274
16:          Grus_canadensis   266
17:     Cygnus_melancoryphus   240
18:     Phthorimaea_absoluta   222
19:        Branta_canadensis   220
20:   Aratinga_leucophthalma   215
21:         Vespa_orientalis   212
22:    Rugulopteryx_okamurae   211
23:        Halyomorpha_halys   207
24:      Columbina_talpacoti   195
25:  Amazonetta_brasiliensis   192
26:     Zebrasoma_flavescens   180
27:       Xylella_fastidiosa   176
28:         Caracara_plancus   171
29:    Cydalima_perspectalis   171
30:        Harmonia_axyridis   165
                   TaxonName     N


########################################################################### FILTERING FOR THE IBERIAN PENINSULA  ############################################################################################

# Required libraries
library(dplyr)
library(stringr)
library(textcat)
library(readr)

# STEP 1: Filter by language: Keep only Spanish or Portuguese
filter_languages <- function(data) {
  data %>%
    mutate(
      title_language = textcat(title),
      description_language = textcat(description)
    ) %>%
    filter(
      title_language %in% c("spanish", "portuguese") |
      description_language %in% c("spanish", "portuguese")
    ) %>%
    select(-title_language, -description_language)
}

# STEP 2: Get GeoNames place names for Spain and Portugal
get_iberian_locations <- function() {
  download_and_read <- function(country_code, col_localidad) {
    temp <- tempfile()
    download.file(paste0("http://download.geonames.org/export/zip/", country_code, ".zip"), temp)
    con <- unz(temp, paste0(country_code, ".txt"))
    data <- read.delim(con, header = FALSE, encoding = "UTF-8")
    unlink(temp)
    colnames(data)[col_localidad] <- "localidad"
    tolower(unique(data$localidad))
  }

  es_locations <- download_and_read("ES", 2)
  pt_locations <- download_and_read("PT", 2)

  unique(c(es_locations, pt_locations))
}

# STEP 3: Filter dataset to include only videos mentioning Iberian localities
filter_iberian_locations <- function(data, locations) {
  pattern <- paste0("\\b(", paste(locations, collapse = "|"), ")\\b")
  data %>%
    filter(
      str_detect(tolower(title), pattern) |
      str_detect(tolower(description), pattern)
    )
}

# ------------------ APPLY FILTERS TO YOUR DATA --------------------

# Replace this with your actual data
# combined_data_NEW_ES_PT_regioncode_scientific_common <- your_loaded_data

# Apply language filter
filtered_language_NEW_ES_PT_regioncode_scientific_common <- filter_languages(combined_data_NEW_ES_PT_regioncode_scientific_common)

# Get Iberian GeoNames locations
iberian_locations <- get_iberian_locations()

# Apply Iberian location filter
filtered_iberian_NEW_ES_PT_regioncode_scientific_common <- filter_iberian_locations(combined_data_NEW_ES_PT_regioncode_scientific_common, iberian_locations)
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common <- filter_iberian_locations(filtered_language_NEW_ES_PT_regioncode_scientific_common, iberian_locations)
filtered_excluded_only_iberian_NEW_ES_PT_regioncode_scientific_common <- filter_iberian_locations(filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common, iberian_locations)


# Summary
cat("Original dataset rows:", nrow(combined_data_NEW_ES_PT_regioncode_scientific_common), "\n")
cat("After language filter:", nrow(filtered_language_NEW_ES_PT_regioncode_scientific_common), "\n")
cat("After Iberian location and language filters:", nrow(filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common), "\n")

# View sample result
print(head(filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common, 5))



library(dplyr)
library(stringr)

# Define a list of non-Iberian Spanish/Portuguese-speaking countries to exclude
exclude_countries <- c(
  "mexico", "argentina", "chile", "colombia", "venezuela", "peru", "bolivia", "paraguay", "uruguay", "ecuador",
  "cuba", "dominican republic", "el salvador", "honduras", "guatemala", "panama", "nicaragua", "puerto rico",
  "brazil", "angola", "mozambique", "cape verde", "guinea-bissau", "sao tome and principe", "timor-leste"
)

# Create a regex pattern with word boundaries
exclude_pattern <- paste0("\\b(", paste0(exclude_countries, collapse = "|"), ")\\b")

# Filter out any rows from `filtered_language_NEW_ES_PT_regioncode_scientific_common` that mention those countries in title or description
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common <- filtered_language_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )

# Filter out any rows from `filtered_language_NEW_ES_PT_regioncode_scientific_common` that mention those countries in title or description
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common <- filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )

# Filter out any rows from `filtered_language_NEW_ES_PT_regioncode_scientific_common` that mention those countries in title or description
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common <- filtered_iberian_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    !str_detect(tolower(title), exclude_pattern) &
    !str_detect(tolower(description), exclude_pattern)
  )


# Optional: View a sample
print(head(filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common, 5))
print(head(filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common, 5))


#############################################################################################################################################################################################################
#############################################################################################################################################################################################################
###############################################3###### DATASET TESTS FROM OLD VERSIONS (JUST TO COMPARE THE FILTERING PROCESS AND OUTPUT) ###################################################################
#############################################################################################################################################################################################################

include_keywords <- c(
  # Spanish (Español)
  "mamíferos", "mamífero", "aves", "ave", "anfibios", "anfibio",
  "reptiles", "reptil", "peces", "pez", "invertebrados", "invertebrado",
  "moluscos", "molusco", "bivalvos", "bivalvo", "cefalópodos", "cefalópodo",
  "artrópodos", "artrópodo", "crustáceos", "crustáceo", "medusas", "medusa",
  "cnidarios", "cnidario", "equinodermos", "equinodermo", "insectos", "insecto",
  "arácnidos", "arácnido", "miriápodos", "miriápodo",

  # Portuguese (Portugal)
  "anfíbios", "anfíbio", "répteis", "réptil", "peixes", "peixe",
  "bivalves", "bivalve", "cefalópodes", "cefalópode", "artrópodes", "artrópode",
  "águas-vivas", "água-viva", "cnidários", "cnidário", "insetos", "inseto",
  "aracnídeos", "aracnídeo", "miriápodes", "miriápode",

  # Catalan (Català)
  "mamífers", "mamífer", "aus", "ocell", "amfibis", "amfibi",
  "rèptils", "rèptil", "peixos", "peix", "invertebrats", "invertebrat",
  "mol·luscs", "mol·lusc", "cefalòpodes", "cefalòpode", "artròpodes", "artròpode",
  "crustacis", "crustaci", "meduses", "cnidaris", "cnidari", "equinoderms",
  "equinoderm", "insectes", "insecte", "aràcnids", "aràcnid", "miriàpodes", "miriàpode",

  # Galician (Galego)
  "réptiles", "peixes", "anfibios", "anfibio",

  # Basque (Euskara)
  "ugaztunak", "ugaztuna", "hegaztiak", "hegaztia", "anfibioak", "anfibioa",
  "narrastiak", "narrastia", "arrainak", "arraina", "ornogabeak", "ornogabea",
  "moluskuak", "moluskua", "bibalboak", "bibalboa", "zefalopodoak", "zefalopodoa",
  "artropodoak", "artropodoa", "krustazeoak", "krustazea", "medusak", "knidarioak",
  "knidarioa", "ekinodermoak", "ekinodermoa", "intsektuak", "intsektua", "araknidoak",
  "araknidoa", "miriapodoak", "miriapodoa",

  # Asturian (Asturianu)
  "mamíferu", "anfibiu", "invertebraos", "invertebrau", "moluscu", "bivalvu",
  "cefalópodu", "artrópodu", "crustáceu", "cnidariu", "equinodermu", "insectu",
  "arácnidu", "miriápodu",

  # Spanish
  "especies invasoras", "especie invasora", "especie", "Especie", "insecto",
  "cotorra", "Insecto", "Cotorra", "amenaza", "ave", "aves", "tortuga",
  "tortugas", "serpiente", "serpientes", "lagartija", "lagartijas", "lagarto",
  "lagartos", "pez", "peces", "anfibio", "anfibios", "naturaleza", "peligrosa",
  "peligrosas", "invasora", "invasoras", "rana", "ranas", "pájaro", "pájaros",
  "reptil", "reptiles", "especie exótica invasora", "especies exóticas invasoras",
  "especie exótica", "especies exóticas", "EEI", "EEIs", "Especies Exóticas Invasoras",
  "Especies exóticas invasoras", "Especie exótica", "Especies exóticas", "Especie Exótica Invasora",
  "Especie exótica invasora", "invasiones biológicas", "invasión biológica", "Invasiones biológicas",
  "Invasión biológica", "especie introducida", "Especie introducida", "especies introducidas",
  "Especies introducidas", "pérdida de biodiversidad", "degradación ambiental", "impacto ecológico",
  "cambio de hábitat", "dispersión", "competencia", "hibridación", "extinción",
  "sobrepoblación", "equilibrio ecológico", "ecosistema", "sostenibilidad",

  # Portuguese (Portugal)
  "espécies invasoras", "espécie invasora", "espécie", "inseto", "papagaio",
  "ameaça", "ave", "aves", "tartaruga", "tartarugas", "serpente", "serpentes",
  "lagartixa", "lagartixas", "lagarto", "lagartos", "peixe", "peixes",
  "anfíbio", "anfíbios", "natureza", "perigosa", "perigosas", "invasora", "invasoras",
  "rã", "rãs", "pássaro", "pássaros", "réptil", "répteis", "espécie exótica invasora",
  "espécies exóticas invasoras", "espécie exótica", "espécies exóticas", "EEI", "EEIs",
  "Espécies Exóticas Invasoras", "Espécies exóticas invasoras", "Espécie exótica",
  "Espécies exóticas", "Espécie Exótica Invasora", "Espécie exótica invasora",
  "invasões biológicas", "invasão biológica", "espécie introduzida", "espécies introduzidas",
  "perda de biodiversidade", "degradação ambiental", "impacto ecológico", "mudança de habitat",
  "dispersão", "competição", "hibridação", "extinção", "superpopulação", "equilíbrio ecológico",
  "ecossistema", "sustentabilidade",

  # Catalan (Català)
  "espècies invasores", "espècie invasora", "espècie", "insecte", "lloro",
  "amenaça", "ocell", "ocells", "tortuga", "tortugues", "serp", "serps",
  "llangardaix", "llangardaixos", "granota", "granotes", "peix", "peixos",
  "amfibi", "amfibis", "natura", "perillosa", "perilloses", "invasora", "invasores",
  "rèptil", "rèptils", "espècie exòtica invasora", "espècies exòtiques invasores",
  "espècie exòtica", "espècies exòtiques", "EEI", "EEIs", "Espècies Exòtiques Invasores",
  "Espècies exòtiques invasores", "Espècie exòtica", "Espècies exòtiques",
  "Espècie Exòtica Invasora", "Espècie exòtica invasora", "invasions biològiques",
  "invasió biològica", "espècie introduïda", "espècies introduïdes", "pèrdua de biodiversitat",
  "degradació ambiental", "impacte ecològic", "canvi d'hàbitat", "dispersió",
  "competència", "hibridació", "extinció", "superpoblació", "equilibri ecològic",
  "ecosistema", "sostenibilitat",

  # Galician (Galego)
  "especies invasoras", "especie invasora", "especie", "insecto", "papagaio",
  "ameaza", "ave", "aves", "tartaruga", "tartarugas", "serpe", "serpes",
  "lagarto", "lagartos", "ra", "ras", "peixe", "peixes", "anfibio", "anfibios",
  "natureza", "perigosa", "perigosas", "invasora", "invasoras", "paxaro", "paxaros",
  "réptil", "réptiles", "especie exótica invasora", "especies exóticas invasoras",
  "especie exótica", "especies exóticas", "EEI", "EEIs", "Especies Exóticas Invasoras",
  "Especies exóticas invasoras", "Especie exótica", "Especies exóticas",
  "Especie Exótica Invasora", "Especie exótica invasora", "invasións biolóxicas",
  "invasión biolóxica", "especie introducida", "especies introducidas",
  "perda de biodiversidade", "degradación ambiental", "impacto ecolóxico",
  "cambio de hábitat", "dispersión", "competencia", "hibridación", "extinción",
  "superpoboación", "equilibrio ecolóxico", "ecosistema", "sustentabilidade",

  # Basque (Euskara)
  "espezie inbaditzaileak", "espezie inbaditzailea", "espezie", "intsektua",
  "loroa", "mehatxua", "txoria", "txoriak", "dortoka", "dortokak", "sugea",
  "sugeak", "muskerra", "muskerrak", "arraina", "arrainak", "anfibioa",
  "anfibioak", "ingurumena", "arriskutsua", "arriskutsuak", "inbaditzailea",
  "inbaditzaileak", "narrastia", "narrastiak", "espezie exotiko inbaditzailea",
  "espezie exotiko inbaditzaileak", "EEI", "EEIs", "espezie sartutakoa",
  "espezie sartutakoak", "inbasio biologikoak", "inbasio biologikoa",
  "ingurumenaren degradazioa", "habitataren aldaketa", "banaketa", "konpetentzia",
  "hibridazioa", "desagertzea", "gehiegizko populazioa", "ekosistema", "iraunkortasuna",

  # Threats and impact of IAS
  "amenaza", "impacto ecológico", "pérdida de biodiversidad", "desequilibrio ecológico",
  "degradación ambiental", "invasiones biológicas", "invasión biológica", "invasora", "invasoras",
  "especie exótica invasora", "especies exóticas invasoras", "competencia ecológica",
  "extinción de especies", "cambio de hábitat", "sobrepoblación", "ecosistema",
  "sostenibilidad", "efecto en la biodiversidad", "dispersión",

  # IAS related taxonomy
  "rana", "ranas", "pájaro", "pájaros", "reptil", "reptiles",
  "tortuga", "tortugas", "serpiente", "serpientes", "lagartija", "lagartijas",
  "lagarto", "lagartos", "pez", "peces", "anfibio", "anfibios",

  # Human-related introduction and consequences
  "especie introducida", "especies introducidas", "invasión ecológica",
  "efecto en la fauna", "impacto ambiental", "contagio de enfermedades",
  "plaga ecológica", "especies invasoras en ríos", "fauna invasora",

  # Portuguese (Portugal)
  "espécies invasoras", "espécie invasora", "espécie", "inseto", "pássaro",
  "papagaio", "sapo", "tartaruga", "cobra", "lagarto", "peixe",
  "ameaça", "impacto ecológico", "perda de biodiversidade", "desequilíbrio ecológico",
  "degradação ambiental", "invasões biológicas", "invasão biológica", "competição ecológica",
  "extinção de espécies", "mudança de habitat", "superpopulação", "ecossistema",
  "sustentabilidade", "efeito na biodiversidade", "dispersão",

  # IAS related taxonomy (Portuguese)
  "rã", "rãs", "réptil", "répteis", "tartarugas", "serpente", "serpentes",
  "lagartixa", "lagartixas", "lagartos", "anfíbio", "anfíbios",
  "espécie exótica invasora", "espécies exóticas invasoras",

  # Human-related introduction and consequences (Portuguese)
  "espécie introduzida", "espécies introduzidas", "invasão ecológica",
  "efeito na fauna", "impacto ambiental", "transmissão de doenças",
  "praga ecológica", "espécies invasoras em rios", "fauna invasora",

  # Catalan (Català)
  "espècies invasores", "espècie invasora", "espècie", "insecte", "ocell",
  "lloro", "granota", "tortuga", "serp", "llangardaix", "peix",
  "amenaça", "impacte ecològic", "pèrdua de biodiversitat", "desequilibri ecològic",
  "degradació ambiental", "invasions biològiques", "invasió biològica",
  "competència ecològica", "extinció d'espècies", "canvi d'hàbitat",
  "superpoblació", "ecosistema", "sostenibilitat", "efecte en la biodiversitat",
  "dispersió",

  # IAS related taxonomy (Catalan)
  "granota", "granotes", "ocell", "ocells", "rèptil", "rèptils", "tortuga", "tortugues",
  "serp", "serps", "llangardaix", "llangardaixos", "peix", "peixos", "amfibi", "amfibis",
  "espècie exòtica invasora", "espècies exòtiques invasores",

  # Human-related introduction and consequences (Catalan)
  "espècie introduïda", "espècies introduïdes", "invasió ecològica",
  "efecte en la fauna", "impacte ambiental", "contagi de malalties",
  "plaga ecològica", "espècies invasores en rius", "fauna invasora",

  # Galician (Galego)
  "especies invasoras", "especie invasora", "especie", "insecto",
  "paxaro", "papagaio", "ra", "tartaruga", "cobreg", "lagarto", "peixe",
  "ameaza", "impacto ecolóxico", "perda de biodiversidade", "desequilibrio ecolóxico",
  "degradación ambiental", "invasións biolóxicas", "invasión biolóxica",
  "competencia ecolóxica", "extinción de especies", "cambio de hábitat",
  "superpoboación", "ecosistema", "sustentabilidade", "efecto na biodiversidade",
  "dispersión",

  # IAS related taxonomy (Galician)
  "ra", "ras", "paxaro", "paxaros", "réptil", "réptiles", "tartaruga",
  "tartarugas", "serpe", "serpes", "lagarto", "lagartos", "anfibio", "anfibios",
  "especie exótica invasora", "especies exóticas invasoras",

  # Human-related introduction and consequences (Galician)
  "especie introducida", "especies introducidas", "invasión ecolóxica",
  "efecto na fauna", "impacto ambiental", "contaxio de enfermidades",
  "praga ecolóxica", "especies invasoras en ríos", "fauna invasora",

  # Basque (Euskara)
  "espezie inbaditzaileak", "espezie inbaditzailea", "espezie",
  "intsektua", "txoria", "loroa", "igela", "dortoka", "sugea", "muskerra", "arraina",
  "mehatxua", "ingurumen-eragina", "biodibertsitate galera", "ekosistemaren desoreka",
  "ingurumenaren degradazioa", "inbasio biologikoak", "inbasio biologikoa",
  "ekosistema", "iraunkortasuna", "banaketa",

  # IAS related taxonomy (Basque)
  "igela", "igelak", "txoria", "txoriak", "narrastia", "narrastiak",
  "dortoka", "dortokak", "sugea", "sugeak", "muskerra", "muskerrak",
  "arraina", "arrainak", "anfibioa", "anfibioak",
  "espezie exotiko inbaditzailea", "espezie exotiko inbaditzaileak",

  # Human-related introduction and consequences (Basque)
  "sartutako espeziea", "sartutako espezieak", "inbasio ekologikoa",
  "ingurumen-eragina", "gaixotasunen kutsapena", "izurrite ekologikoa",
  "ibaietako espezie inbaditzaileak", "fauna inbaditzailea"
)


exclude_keywords <- c(
  # English & Spanish
  "soccer", "football", "gaming", "entertainment", "movie", "movies",
  "game", "games", "videogame", "basketball", "videogames", "music",
  "concert", "teams", "team", "tournament", "tournaments", "series",
  "videojuego", "juego", "videojuegos", "juegos", "partido", "partidos",
  "fútbol", "baloncesto", "música", "gamer", "gamers", "jugador", "jugadores",
  "sports", "película", "películas", "consola", "consolas", "canción",
  "canciones", "bailar", "baile", "bailes", "moda", "ropa", "celebridad",
  "humor", "comedia", "entretenimiento", "noticias falsas", "clickbait",
  "viral", "memes", "tecnología", "ciencia ficción", "inteligencia artificial",

  "São Paulo", "Elden Ring", "Pica-Pau", "PICA-PAU", "Red Dead Redemption",
  "Brasileiro", "Cartoons", "Depilação", "Consolador", "Peppa Pig", "Gameplay",
  "Pokemon", "Lets Play", "Dragon Ball Z", "Pocoyo", "Chile", "Brasil",
  "Assassin's Creed", "Argentina", "Assassins Creed", "PlayStation", "Playstation",
  "Xbox",

  # Portuguese (Portugal)
  "futebol", "basquetebol", "jogos", "gaming", "jogo", "videojogo",
  "videojogos", "música", "concerto", "equipas", "equipa", "torneio",
  "torneios", "série", "séries", "filme", "filmes", "desporto", "jogador",
  "jogadores", "consola", "consolas", "canção", "canções", "dança", "dançar",
  "danças", "moda", "roupa", "celebridade", "famoso", "famosos", "humor",
  "comédia", "entretenimento", "notícias falsas", "clickbait", "viral",
  "memes", "tecnologia", "ficção científica", "inteligência artificial",

  # Catalan (Català)
  "futbol", "bàsquet", "jocs", "joc", "videojoc", "videojocs", "música",
  "concert", "equips", "equip", "torneig", "tornejos", "sèrie", "sèries",
  "pel·lícula", "pel·lícules", "esports", "jugador", "jugadors", "consola",
  "consoles", "cançó", "cançons", "ballar", "ball", "balls", "moda", "roba",
  "celebritat", "humor", "comèdia", "entreteniment", "notícies falses",
  "clickbait", "viral", "mems", "tecnologia", "ciència-ficció",
  "intel·ligència artificial",

  # Galician (Galego)
  "fútbol", "baloncesto", "xogos", "xogo", "videoxogo", "videoxogos", "música",
  "concerto", "equipos", "equipo", "torneo", "torneos", "serie", "series",
  "película", "películas", "deporte", "xogador", "xogadores", "consola",
  "consolas", "canción", "cancións", "bailar", "baile", "bailes", "moda",
  "roupa", "celebridade", "humor", "comedia", "entretenemento",
  "novas falsas", "clickbait", "viral", "memes", "tecnoloxía",
  "ciencia ficción", "intelixencia artificial",

  # Basque (Euskara)
  "futbola", "saskibaloia", "jokoak", "jokoa", "bideojokoa", "bideojokoak",
  "musika", "kontzertua", "taldeak", "taldea", "txapelketa", "txapelketak",
  "saioa", "saioak", "filma", "filmak", "kirola", "jokalaria", "jokalariak",
  "kontsola", "kontsolak", "kanta", "kantak", "dantza", "moda", "arropa",
  "ospetsua", "umorea", "komedia", "aisialdia", "albiste faltsuak",
  "clickbait", "birala", "memak", "teknologia", "fikzio zientifikoa",
  "adimen artifiziala",

  # Asturian (Asturianu)
  "fútbol", "baloncestu", "xuegos", "xuegu", "videoxuegu", "videoxuegos",
  "música", "conciertu", "equipos", "equipu", "torneu", "torneos", "serie",
  "series", "película", "películes", "deporte", "xugador", "xugadores",
  "consola", "consoles", "canción", "canciones", "bailar", "baile", "bailes",
  "moda", "ropa", "celebritá", "humor", "comedia", "entretenimientu",
  "noticies falses", "clickbait", "viral", "memes", "tecnoloxía",
  "ciencia ficción", "intelixencia artificial"
)



library(dplyr)
library(stringr)

# Combine description text to lower case (if not already)
combined_data_NEW_ES_PT_regioncode_scientific_common_lower <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  mutate(full_description_lower = tolower(description))

# Inclusion filter (any include keyword matches)
filtered_included_only_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common_lower %>%
  filter(str_detect(full_description_lower, paste0("\\b(", paste(include_keywords, collapse = "|"), ")\\b")))

# Exclusion filter (remove rows with any exclude keyword)
filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common_lower %>%
  filter(!str_detect(full_description_lower, paste0("\\b(", paste(exclude_keywords, collapse = "|"), ")\\b")))

# Combined filter (inclusion AND NOT exclusion)
filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common <- combined_data_NEW_ES_PT_regioncode_scientific_common_lower %>%
  filter(
    str_detect(full_description_lower, paste0("\\b(", paste(include_keywords, collapse = "|"), ")\\b")) &
    !str_detect(full_description_lower, paste0("\\b(", paste(exclude_keywords, collapse = "|"), ")\\b"))
  )


# Optional: check sizes
cat("?? Combined (include and not exclude):", nrow(filtered_included_only_NEW_ES_PT_regioncode_scientific_common), "rows\n")
?? Combined (include and not exclude): 1474 rows

cat("? Excluded only (removed unwanted):", nrow(filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common), "rows\n")
Excluded only (removed unwanted): 11689 rows

cat("?? Combined (include and not exclude):", nrow(filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common), "rows\n")
?? Combined (include and not exclude): 1450 rows


#############################################################################################################################################################################################################

library(dplyr)
library(stringr)
library(readr)

# Step 1: Load and Clean Spanish & Portuguese Locations from Geonames
load_geonames <- function(country_code, col_indices) {
  temp <- tempfile()
  url <- paste0("http://download.geonames.org/export/zip/", country_code, ".zip")
  download.file(url, temp)
  con <- unz(temp, paste0(country_code, ".txt"))
  df <- read.delim(con, header = FALSE, encoding = "UTF-8")
  unlink(temp)

  colnames(df)[col_indices] <- c("comunidad", "ciudad", "localidad")
  df <- df[col_indices]
  df <- unique(tolower(unlist(df)))  # Flatten to a unique vector
  df <- df[df != ""]  # Remove empty values
  return(df)
}

localities_ES <- load_geonames("ES", c(4, 6, 8))
localities_PT <- load_geonames("PT", c(3, 4, 8))

# Combine and clean location lists
localities_all <- unique(c(localities_ES, localities_PT))
localities_all <- localities_all[!is.na(localities_all)]

# Step 2: Keep videos mentioning Spain/Portugal locations OR missing location info
filter_by_location <- function(data, locations) {
  data %>% filter(
    str_detect(tolower(title), paste(locations, collapse = "|") ) |
    str_detect(tolower(description), paste(locations, collapse = "|")) |
    is.na(title) | is.na(description)
  )
}
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2 <- filter_by_location(combined_data_NEW_ES_PT_regioncode_scientific_common, localities_all)
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2 <- filter_by_location(filtered_language_NEW_ES_PT_regioncode_scientific_common, localities_all)
filtered_excluded_only_iberian_NEW_ES_PT_regioncode_scientific_common_2 <- filter_by_location(filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common, localities_all)


# Step 3: Exclude non-Iberian Spanish/Portuguese-speaking countries
exclude_countries <- c("mexico", "argentina", "chile", "colombia", "venezuela", "peru", "brazil",
                       "ecuador", "uruguay", "paraguay", "bolivia", "guatemala", "honduras",
                       "el salvador", "dominican republic", "panama", "nicaragua", "cuba",
                       "angola", "mozambique", "cape verde", "guinea-bissau", "sao tome and principe", "equatorial guinea")

exclude_regex <- paste0("\\b(", paste(exclude_countries, collapse = "|"), ")\\b")



filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2 <- filtered_language_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )

filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2 <- filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2 %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )

filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2 <- filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2 %>%
  filter(
    !(str_detect(tolower(title), exclude_regex) |
      str_detect(tolower(description), exclude_regex))
  )


# Step 2: Filter by Keywords
filter_by_keywords <- function(data, include_keywords, exclude_keywords) {
  data %>%
    filter(
      str_detect(title, paste(include_keywords, collapse = "|")) |
        str_detect(description, paste(include_keywords, collapse = "|"))
    ) %>%
    filter(
      !str_detect(title, paste(exclude_keywords, collapse = "|")) &
        !str_detect(description, paste(exclude_keywords, collapse = "|"))
    )
}


library(dplyr)
library(stringr)
library(textcat)

# ---- Step 1: Prepare Localities ----
prepare_localities <- function() {
  # Download and process Spanish localities
  temp_es <- tempfile()
  download.file("http://download.geonames.org/export/zip/ES.zip", temp_es)
  con_es <- unz(temp_es, "ES.txt")
  localities_ES <- read.delim(con_es, header = FALSE)
  unlink(temp_es)
  colnames(localities_ES)[c(4, 6, 8)] <- c("comunidad", "ciudad", "localidad")
  localities_ES <- localities_ES[c(4, 6, 8)]
  localities_ES$localidad <- tolower(localities_ES$localidad)

  # Download and process Portuguese localities
  temp_pt <- tempfile()
  download.file("http://download.geonames.org/export/zip/PT.zip", temp_pt)
  con_pt <- unz(temp_pt, "PT.txt")
  localities_PT <- read.delim(con_pt, header = FALSE)
  unlink(temp_pt)
  colnames(localities_PT)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
  localities_PT <- localities_PT[c(3, 4, 8)]
  localities_PT$localidad <- tolower(localities_PT$localidad)

  # Combine both
  localities_NEW_ES_PT_regioncode_scientific_common_ALL3 <- full_join(localities_PT, localities_ES, by = c("comunidad", "ciudad", "localidad"))
  unique(tolower(localities_NEW_ES_PT_regioncode_scientific_common_ALL3$localidad))
}

# ---- Step 2: Filtering Functions ----

# Filter by keywords (include and optionally exclude)
filter_by_keywords <- function(data, include_keywords, exclude_keywords = NULL) {
  data_filtered <- data %>%
    filter(
      str_detect(tolower(title), paste(include_keywords, collapse = "|")) |
        str_detect(tolower(description), paste(include_keywords, collapse = "|"))
    )

  if (!is.null(exclude_keywords)) {
    data_filtered <- data_filtered %>%
      filter(
        !str_detect(tolower(title), paste(exclude_keywords, collapse = "|")) &
        !str_detect(tolower(description), paste(exclude_keywords, collapse = "|"))
      )
  }

  return(data_filtered)
}

# Filter by detected language
filter_by_language <- function(data, target_languages = c("spanish", "portuguese")) {
  data %>%
    mutate(detected_language = textcat::textcat(description)) %>%
    filter(detected_language %in% target_languages)
}

# Filter by location (title or description contains locality)
filter_by_location <- function(data, locations) {
  data %>%
    filter(
      str_detect(tolower(title), paste(locations, collapse = "|")) |
        str_detect(tolower(description), paste(locations, collapse = "|"))
    )
}

# ---- Step 3: Master Filtering Function ----
process_youtube_data <- function(data, include_keywords, exclude_keywords, locations) {
  data %>%
    filter_by_keywords(include_keywords, exclude_keywords) %>%
    filter_by_language(target_languages = c("spanish", "portuguese")) %>%
    filter_by_location(locations)
}

# ---- Step 4: Apply Filtering ----

# Prepare localities (only once)
localities_vector <- prepare_localities()

# Assume you already have these lists defined in your session
# include_keywords <- c("invasive", "species", ...)  # etc.
# exclude_keywords <- c("non-invasive", ...)         # optional

# Now apply the filters individually if needed
filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3 <- filter_by_keywords(
  combined_data_NEW_ES_PT_regioncode_scientific_common,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords
)

filtered_Iberian_NEW_ES_PT_regioncode_scientific_common_3 <- filter_by_location(
  combined_data_NEW_ES_PT_regioncode_scientific_common,
  locations = localities_vector
)

filtered_language_NEW_ES_PT_regioncode_scientific_common_3 <- filter_by_language(
  combined_data_NEW_ES_PT_regioncode_scientific_common,
  target_languages = c("spanish", "portuguese")
)

# Or apply all filters together
filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3 <- process_youtube_data(
  combined_data_NEW_ES_PT_regioncode_scientific_common,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)


# Prepare localities (if not already created)
localities_vector <- prepare_localities()

# Now call with all required arguments:
filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3 <- process_youtube_data(
  filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3 <- process_youtube_data(
  filtered_included_only_NEW_ES_PT_regioncode_scientific_common,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3 <- process_youtube_data(
  filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common,
  include_keywords = include_keywords,
  exclude_keywords = exclude_keywords,
  locations = localities_vector
)

# Step 1: Prepare exclusion localities (as previously done)
prepare_exclusion_localities_refined <- function() {
    countries <- c("MX", "AR", "CL", "CO", "VE", "BO", "PY", "UY", "PE", "EC", "BR", "DO", "CR", "GT", "HN", "SV", "NI", "CU", "PA")
    exclusion_localities <- list()

    for (country in countries) {
        cat("Processing country:", country, "\n")
        temp_file <- tempfile()
        download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

        tryCatch({
            download.file(download_url, temp_file)
            con <- unz(temp_file, paste0(country, ".txt"))
            country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
            unlink(temp_file)

            colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
            localities <- country_data[, c("localidad", "comunidad", "ciudad")]
            localities <- unique(tolower(unlist(localities)))
            exclusion_localities <- c(exclusion_localities, localities)
        }, error = function(e) {
            cat("Skipping country:", country, "due to missing or inaccessible file.\n")
        })
    }

    # Escape special characters and filter out overly generic terms
    exclusion_localities <- str_replace_all(exclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
    exclusion_localities <- exclusion_localities[!exclusion_localities %in% c("centro", "primavera", "del carmen")]

    unique(exclusion_localities)
}

# Prepare the exclusion localities
exclusion_localities <- prepare_exclusion_localities_refined()

# Step 2: Create regex pattern with stricter word boundaries
exclusion_pattern <- paste0("\\b(", paste(unique(exclusion_localities), collapse = "|"), ")\\b")

# Step 3: Apply the exclusion filter with the refined pattern
filter_by_exclusion_refined <- function(data, pattern) {
    data %>%
        filter(
            !str_detect(tolower(title), pattern) &
                !str_detect(tolower(description), pattern)
        )
}

# Step 4: Apply the filter to the dataset
filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4 <- filter_by_exclusion_refined(
    combined_data_NEW_ES_PT_regioncode_scientific_common, exclusion_pattern
)


library(dplyr)
library(stringr)

# Step 1: Prepare inclusion localities from Iberian regions
prepare_inclusion_localities_iberian <- function() {
  iberian_countries <- c("PT", "ES")  # Portugal and Spain include regions like Azores, Madeira, Canary
  inclusion_localities <- list()

  for (country in iberian_countries) {
    cat("Processing country:", country, "\n")
    temp_file <- tempfile()
    download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

    tryCatch({
      download.file(download_url, temp_file)
      con <- unz(temp_file, paste0(country, ".txt"))
      country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
      unlink(temp_file)

      colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
      localities <- country_data[, c("localidad", "comunidad", "ciudad")]
      localities <- unique(tolower(unlist(localities)))
      inclusion_localities <- c(inclusion_localities, localities)
    }, error = function(e) {
      cat("Skipping country:", country, "due to missing or inaccessible file.\n")
    })
  }

  # Clean up and return
  inclusion_localities <- str_replace_all(inclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
  unique(inclusion_localities)
}

# Prepare Iberian inclusion localities
inclusion_localities <- prepare_inclusion_localities_iberian()
inclusion_pattern <- paste0("\\b(", paste(unique(inclusion_localities), collapse = "|"), ")\\b")

# Step 2: Apply the Iberian inclusion filter only
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4 <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    str_detect(tolower(title), inclusion_pattern) |
    str_detect(tolower(description), inclusion_pattern)
  )


# Step 1: Prepare exclusion localities (non-Iberian countries)
prepare_exclusion_localities_refined <- function() {
  countries <- c("MX", "AR", "CL", "CO", "VE", "BO", "PY", "UY", "PE", "EC", "BR", "DO", "CR", "GT", "HN", "SV", "NI", "CU", "PA")
  exclusion_localities <- list()

  for (country in countries) {
    cat("Processing country:", country, "\n")
    temp_file <- tempfile()
    download_url <- paste0("http://download.geonames.org/export/zip/", country, ".zip")

    tryCatch({
      download.file(download_url, temp_file)
      con <- unz(temp_file, paste0(country, ".txt"))
      country_data <- read.delim(con, header = FALSE, encoding = "UTF-8")
      unlink(temp_file)

      colnames(country_data)[c(3, 4, 8)] <- c("localidad", "comunidad", "ciudad")
      localities <- country_data[, c("localidad", "comunidad", "ciudad")]
      localities <- unique(tolower(unlist(localities)))
      exclusion_localities <- c(exclusion_localities, localities)
    }, error = function(e) {
      cat("Skipping country:", country, "due to missing or inaccessible file.\n")
    })
  }

  exclusion_localities <- str_replace_all(exclusion_localities, "([.()\\[\\]{}+?*|^$\\-])", "\\\\\\1")
  exclusion_localities <- exclusion_localities[!exclusion_localities %in% c("centro", "primavera", "del carmen")]
  unique(exclusion_localities)
}

# Reuse Iberian locality inclusion from script #1
inclusion_localities <- prepare_inclusion_localities_iberian()
exclusion_localities <- prepare_exclusion_localities_refined()

# Create regex patterns
inclusion_pattern <- paste0("\\b(", paste(unique(inclusion_localities), collapse = "|"), ")\\b")
exclusion_pattern <- paste0("\\b(", paste(unique(exclusion_localities), collapse = "|"), ")\\b")

# Step 2: Apply both filters
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4 <- combined_data_NEW_ES_PT_regioncode_scientific_common %>%
  filter(
    !str_detect(tolower(title), exclusion_pattern) &
    !str_detect(tolower(description), exclusion_pattern) &
    (
      str_detect(tolower(title), inclusion_pattern) |
      str_detect(tolower(description), inclusion_pattern)
    )
  )


#################################################################################### DATASETS SUMMARY RESULTS ###############################################################################################

# Load necessary library
library(dplyr)

# List of datasets you have loaded in your environment
dataset_names <- c(
  "filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4",
  "filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4",
  "filtered_iberian_NEW_ES_PT_regioncode_scientific_common",
  "filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common",
  "filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common",
  "filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_language_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common",
  "filtered_included_only_NEW_ES_PT_regioncode_scientific_common",
  "filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common",
  "filtered_language_NEW_ES_PT_regioncode_scientific_common",
  "filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2",
  "filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common",
  "filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2",
  "filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2",
  "filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_3",
  "filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2",
  "filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2",
  "filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4"
)

# Descriptions (in the same order)
dataset_descriptions <- c(
  "After Iberian (method 4), non_iberian_counties excluded (method 4)",
  "After non_iberian_counties excluded (method 4)",
  "After Iberian filter (method 1)",
  "After Iberian filter (method 1), non_iberian_counties excluded (method 1)",
  "After language and Iberian (method 1) location filters",
  "After keywords filter (include and not exclude), language (method 3) and Iberian (method 3) filters",
  "After keywords filter (included only), language (method 3) and Iberian (method 3) filters",
  "After keywords filter (exclude only), language (method 3) and Iberian (method 3) filters",
  "After keywords, language (method 3) and Iberian (method 3) location filters",
  "After keywords filter (method 3)",
  "After language filter (method 3)",
  "After keywords filter (include and not exclude)",
  "After keywords filter (include only)",
  "After keywords filter (exclude only)",
  "After language filter (method 1)",
  "After language (method 1) and Iberian (method 2) location filters",
  "After language (method 3) and Iberian (method 3) location filters",
  "After language filter, non_iberian_counties excluded (method 1)",
  "After language filter, non_iberian_counties excluded (method 2)",
  "After language and Iberian (method 2) location filters, non_iberian_counties excluded (method 2)",
  "After language (method 3) and Iberian (method 3) location filters, non_iberian_counties excluded (method 3)",
  "After Iberian filter (method 2)",
  "After Iberian filter (method 2), non_iberian_counties excluded (method 2)",
  "After Iberian filter (method 4)"
)

# Create a data frame by looping through dataset names and calculating nrow
dataset_info <- data.frame(
  Dataset = dataset_names,
  Description = dataset_descriptions,
  Row_Count = sapply(dataset_names, function(x) {
    if (exists(x)) {
      nrow(get(x))
    } else {
      NA  # In case any dataset is missing
    }
  }),
  stringsAsFactors = FALSE
)

# Sort the resulting table by Row_Count
dataset_info_sorted <- dataset_info %>%
  arrange(Row_Count)

# View
print(dataset_info_sorted)

Dataset
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                               filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4
filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                                               filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common                                                                           filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                                                   filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common
filtered_iberian_NEW_ES_PT_regioncode_scientific_common                                                                                             filtered_iberian_NEW_ES_PT_regioncode_scientific_common
filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3 filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3
filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3                         filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3
filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common                                                         filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common
filtered_included_only_NEW_ES_PT_regioncode_scientific_common                                                                                 filtered_included_only_NEW_ES_PT_regioncode_scientific_common
filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3                         filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3
filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                                     filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3
filtered_language_NEW_ES_PT_regioncode_scientific_common_3                                                                                       filtered_language_NEW_ES_PT_regioncode_scientific_common_3
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                             filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                                                 filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                                             filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2                                                                       filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2
filtered_language_NEW_ES_PT_regioncode_scientific_common                                                                                           filtered_language_NEW_ES_PT_regioncode_scientific_common
filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3                                                                                       filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                                               filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2
filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common                                                                                 filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2                                                                                         filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4                                                                                         filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                                                       filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_3
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_3                             filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_3
                                                                                                                                                                                                      Description
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                                                 After Iberian (method 4), non_iberian_counties excluded (method 4)
filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                                                                             After non_iberian_counties excluded (method 4)
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common                                                                                           After language and Iberian (method 1) location filters
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                                                            After Iberian filter (method 1), non_iberian_counties excluded (method 1)
filtered_iberian_NEW_ES_PT_regioncode_scientific_common                                                                                                                           After Iberian filter (method 1)
filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3         After keywords filter (include and not exclude), language (method 3) and Iberian (method 3) filters
filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3                               After keywords filter (included only), language (method 3) and Iberian (method 3) filters
filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common                                                                                         After keywords filter (include and not exclude)
filtered_included_only_NEW_ES_PT_regioncode_scientific_common                                                                                                                After keywords filter (include only)
filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3                                After keywords filter (exclude only), language (method 3) and Iberian (method 3) filters
filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                                           After keywords, language (method 3) and Iberian (method 3) location filters
filtered_language_NEW_ES_PT_regioncode_scientific_common_3                                                                                                                       After language filter (method 3)
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                          After language and Iberian (method 2) location filters, non_iberian_counties excluded (method 2)
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                                                                     After language filter, non_iberian_counties excluded (method 1)
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                                                                   After language filter, non_iberian_counties excluded (method 2)
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2                                                                              After language (method 1) and Iberian (method 2) location filters
filtered_language_NEW_ES_PT_regioncode_scientific_common                                                                                                                         After language filter (method 1)
filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3                                                                                                                       After keywords filter (method 3)
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                                                          After Iberian filter (method 2), non_iberian_counties excluded (method 2)
filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common                                                                                                                After keywords filter (exclude only)
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2                                                                                                                         After Iberian filter (method 2)
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4                                                                                                                         After Iberian filter (method 4)
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                                                              After language (method 3) and Iberian (method 3) location filters
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_3               After language (method 3) and Iberian (method 3) location filters, non_iberian_counties excluded (method 3)
                                                                                                      Row_Count
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                0
filtered_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_4                                        0
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common                                             15
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                                 58
filtered_iberian_NEW_ES_PT_regioncode_scientific_common                                                      67
filtered_keywords_language_iberian_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common_3       991
filtered_keywords_language_iberian_included_only_NEW_ES_PT_regioncode_scientific_common_3                   991    *
filtered_included_and_not_excluded_NEW_ES_PT_regioncode_scientific_common                                  1450    *
filtered_included_only_NEW_ES_PT_regioncode_scientific_common                                              1474
filtered_keywords_language_iberian_excluded_only_NEW_ES_PT_regioncode_scientific_common_3                  4017
filtered_keywords_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                4017    *
filtered_language_NEW_ES_PT_regioncode_scientific_common_3                                                 5154
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                    5283    *
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common                              5414
filtered_language_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                            5416
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_2                                         6935
filtered_language_NEW_ES_PT_regioncode_scientific_common                                                   7068
filtered_keywords_NEW_ES_PT_regioncode_scientific_common_3                                                 7893
filtered_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_2                            10775     *   SELECTED
filtered_excluded_only_NEW_ES_PT_regioncode_scientific_common                                             11689
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_2                                                 15795
filtered_iberian_NEW_ES_PT_regioncode_scientific_common_4                                                 16519     *
filtered_language_iberian_NEW_ES_PT_regioncode_scientific_common_3                                           NA
filtered_language_iberian_non_iberian_counties_NEW_ES_PT_regioncode_scientific_common_3                      NA


############################################################################################################################################################################################################



