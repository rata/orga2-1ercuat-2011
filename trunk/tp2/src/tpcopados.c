#include <getopt.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "color.h"
#include "filtros.h"
#include "tiempo.h"
#include "utils.h"

typedef void (filtro_t) (unsigned char*, unsigned char*, int, int, int);
typedef void (gris_t) (unsigned char*, unsigned char*, int, int, int, int);

typedef struct {
	char *nombre_largo_filtro;
	char *nombre_corto_filtro;
	filtro_t *filtro_asm;
	filtro_t *filtro_c;	
} filtro_info_t;

const char* nombre_programa;

void imprimir_ayuda ( ) {
	printf ( "Uso: %s opciones nombre_archivo_entrada [nombre_archivo_salida]\n", nombre_programa );
	printf ( "    -f, --filtro NOMBRE_FILTRO                 Aplica un filtro a la imagen. Los filtros disponibles    \n" );
	printf ( "                                               son: roberts (r), prewitt (p), sobel (s), freichen (f)   \n" );
	printf ( "                                                                                                        \n" );
	printf ( "    -g, --escala-gris NOMBRE_GRIS              Convierte la imagen a escala de gris. Los métodos        \n" );
	printf ( "                                               disponibles son: uno (u), infinito (i)                   \n" );	
	printf ( "                                                                                                        \n" );	
	printf ( "    -h, --help                                 Imprime esta ayuda                                       \n" );
	printf ( "                                                                                                        \n" );
	printf ( "    -i, --implementacion NOMBRE_MODO           Implementación sobre la que se ejecutará el proceso      \n" );
	printf ( "                                               seleccionado. Los implementaciones disponibles           \n" );
	printf ( "                                               son: c, asm                                              \n" );
	printf ( "                                                                                                        \n" );
	printf ( "    -t, --tiempo CANT_ITERACIONES              Mide el tiempo que tarda en ejecutar el filtro sobre la  \n" );
	printf ( "                                               imagen de entrada una cantidad de veces igual a          \n" );
	printf ( "                                               CANT_ITERACIONES                                         \n" );	
	printf ( "                                                                                                        \n" );	
	printf ( "    -v, --verbose                              Imprime información adicional                            \n" );
	printf ( "                                                                                                        \n" );
}

int main( int argc, char** argv ) {
	int siguiente_opcion;

	// Opciones
	const char* const op_cortas = "f:g:hi:vt:";

	const struct option op_largas[] = {
		{ "filtro", 1, NULL, 'f' },
		{ "escala-gris", 1, NULL, 'g' },
		{ "help", 0, NULL, 'h' },
		{ "implementacion", 1, NULL, 'i' },
		{ "verbose", 0, NULL, 'v' },
		{ "tiempo", 1, NULL, 't' },
		{ NULL, 0, NULL, 0 }
	};
	
	filtro_info_t filtros[] = {
		{"roberts", "r", roberts_asm, roberts_c},
		{"prewitt", "p", prewitt_asm, prewitt_c},
		{"sobel", "s", sobel_asm, sobel_c},
		{"freichen", "f", freichen_asm, freichen_c},
		{ NULL, 0, NULL, 0 }
	};

	// Parametros
	const char* nombre_filtro = NULL;
	const char* nombre_implementacion = NULL;
	const char* nombre_gris = NULL;
	int cant_iteraciones = 0;

	// Flags de opciones
	int verbose = 0;
	int tiempo = 0;
	int convertir_gris = 0;
	int aplicar_filtro = 0;
	
	int indice_filtro = -1;

	// Guardar nombre del programa para usarlo en la ayuda
	nombre_programa = argv[0];

	// Si se ejecuta sin parametros ni opciones
	if ( argc == 1 ) {
		imprimir_ayuda ( );

		exit ( EXIT_SUCCESS );
	}

	while ( 1 ) {
		siguiente_opcion = getopt_long ( argc, argv, op_cortas, op_largas, NULL);

		// No hay mas opciones
		if ( siguiente_opcion == -1 )
			break;

		// Procesar opcion
		switch ( siguiente_opcion ) {		
			case 'f' : /* -f o --filtro */
				aplicar_filtro = 1;
				nombre_filtro = optarg;
				break;			
			case 'g' : /* -g o --escala-gris */
				convertir_gris = 1;
				nombre_gris = optarg;
				break;								
			case 'h' : /* -h o --help */
				imprimir_ayuda ( );
				exit ( EXIT_SUCCESS );
				break;
			case 'i' : /* -i o --implementacion */
				nombre_implementacion = optarg;
				break;
			case 't' : /* -t o --tiempo */
				tiempo = 1;
				cant_iteraciones = atoi ( optarg );
				break;				
			case 'v' : /* -v o --verbose */
				verbose = 1;
				break;
			case '?' : /* opcion no valida */
				imprimir_ayuda ( );
				exit ( EXIT_SUCCESS );
			default : /* opcion no valida */
				abort ( );
		}
	}
	
	if (strncmp(nombre_implementacion, "c", 1)!=0 && 
		strncmp(nombre_implementacion, "asm", 3)!=0) {
		imprimir_ayuda ( );
		exit ( EXIT_SUCCESS );
	}
	
	if (aplicar_filtro && convertir_gris) {
		printf("No se puede aplicar el filtro y convertir a escala de gris al mismo tiempo.\n");
		imprimir_ayuda ( );
		exit ( EXIT_SUCCESS );	
	}
		
	if (aplicar_filtro) {
		for (int i=0; filtros[i].nombre_largo_filtro; i++) {
			if (strcmp(nombre_filtro, filtros[i].nombre_largo_filtro)==0 ||
				strcmp(nombre_filtro, filtros[i].nombre_corto_filtro)==0) {
				indice_filtro = i;
			}			
		}
		
		if (indice_filtro==-1) {
			imprimir_ayuda ( );
			exit ( EXIT_SUCCESS );		
		}
		
		// Procesar imagen		
		filtro_t *filtro = NULL;
		
		IplImage *src = 0;
		IplImage *dst = 0;

		char *nomb_arch_entrada;
		char nomb_arch_salida[256];

		memset(nomb_arch_salida, 0, 256);

		nomb_arch_entrada = argv[optind];
				
		if (++optind==argc) {
			// Genero nombre de archivo se salida	
			strcpy ( nomb_arch_salida, nomb_arch_entrada);
			strcat ( nomb_arch_salida, "." );
			strcat ( nomb_arch_salida, nombre_filtro );
			strcat ( nomb_arch_salida, "." );
			strcat ( nomb_arch_salida, nombre_implementacion );
			strcat ( nomb_arch_salida, ".bmp");
		} else {
			strcpy ( nomb_arch_salida, argv[optind] );
		}
				
		// Cargo la imagen
		if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
			return -1;

		// Creo una IplImage para cada salida esperada
		if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
			return -1;
			
		// Imprimo info
		if ( verbose ) {
			printf ( "Filtrando imagen...\n");
			printf ( "  Filtro             : %s\n", nombre_filtro);
			printf ( "  Implementación     : %s\n", nombre_implementacion);
			printf ( "  Archivo de entrada : %s\n", nomb_arch_entrada);
			printf ( "  Archivo de salida  : %s\n", nomb_arch_salida);		
		}				

		// Selecciono el filtro
		filtro = strcmp(nombre_implementacion, "c")==0?filtros[indice_filtro].filtro_c:filtros[indice_filtro].filtro_asm;	

		// Aplico filtro
		if (filtro) {
			if (tiempo) {
				unsigned long long int start, end;
				unsigned long long int cant_ciclos;
				
				MEDIR_TIEMPO_START(start);
				
				for(int i=0; i<cant_iteraciones; i++) {
					filtro((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
				}
				
				MEDIR_TIEMPO_STOP(end);
				
				cant_ciclos = end-start;
				
				printf("Tiempo de ejecución:\n");
				printf("  Comienzo                          : %llu\n", start);
				printf("  Fin                               : %llu\n", end);
				printf("  # iteraciones                     : %d\n", cant_iteraciones);
				printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
				printf("  # de ciclos insumidos por llamada : %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);
			} else {
				filtro((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
			}		
			
			copiar_bordes((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
		}

		// Guardo imagen y libero las imagenes
		cvSaveImage(nomb_arch_salida, dst, NULL);

		cvReleaseImage(&src);
		cvReleaseImage(&dst);		
	}
	
	
	if (convertir_gris) {
		// Procesar imagen		
		gris_t *gris = NULL;
					
		IplImage *src = 0;
		IplImage *dst = 0;

		char *nomb_arch_entrada;
		char nomb_arch_salida[256];

		memset(nomb_arch_salida, 0, 256);

		nomb_arch_entrada = argv[optind];
				
		if (++optind==argc) {
			// Genero nombre de archivo se salida	
			strcpy ( nomb_arch_salida, nomb_arch_entrada);
			strcat ( nomb_arch_salida, "." );
			strcat ( nomb_arch_salida, nombre_gris );
			strcat ( nomb_arch_salida, "." );
			strcat ( nomb_arch_salida, nombre_implementacion );
			strcat ( nomb_arch_salida, ".bmp");
		} else {
			strcpy ( nomb_arch_salida, argv[optind] );
		}
				
		// Cargo la imagen
		if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_COLOR)) == 0 )
			return -1;

		// Creo una IplImage para cada salida esperada
		if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
			return -1;
			
		// Imprimo info
		if ( verbose ) {
			printf ( "Convirtiendo imagen...\n");
			printf ( "  Método             : %s\n", nombre_gris);
			printf ( "  Implementación     : %s\n", nombre_implementacion);
			printf ( "  Archivo de entrada : %s\n", nomb_arch_entrada);
			printf ( "  Archivo de salida  : %s\n", nomb_arch_salida);
		}	
		
		// Selecciono el metodo de escala de gris		
		if (strncmp(nombre_gris, "uno", 3)==0 || strncmp(nombre_gris, "u", 1)==0) {
			if (strncmp(nombre_implementacion, "c", 1)==0) {
				gris = gris_epsilon_uno_c;
			} else {
				gris = gris_epsilon_uno_asm;				
			}
		}
			
		if (strncmp(nombre_gris, "infinito", 3)==0 || strncmp(nombre_gris, "i", 1)==0) {
			if (strncmp(nombre_implementacion, "c", 1)==0) {
				gris = gris_epsilon_inf_c;
			} else {
				gris = gris_epsilon_inf_asm;							
			}
		}
							
		if (tiempo) {
			unsigned long long int start, end;
			unsigned long long int cant_ciclos;
			
			MEDIR_TIEMPO_START(start);
			
			for(int i=0; i<cant_iteraciones; i++) {
				gris((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
			}
			
			MEDIR_TIEMPO_STOP(end);
			
			cant_ciclos = end-start;
			
			printf("Tiempo de ejecución:\n");
			printf("  Comienzo                          : %llu\n", start);
			printf("  Fin                               : %llu\n", end);
			printf("  # iteraciones                     : %d\n", cant_iteraciones);
			printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
			printf("  # de ciclos insumidos por llamada : %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);
		} else {
			gris((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
		}	
				
		// Guardo imagen y libero los "handlers"
		cvSaveImage(nomb_arch_salida, dst, NULL);

		cvReleaseImage(&src);
		cvReleaseImage(&dst);
	}	

	return 0;
}
