package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"event-planner/backend/internal/auth"
	"event-planner/backend/internal/config"
	"event-planner/backend/internal/db"
	"event-planner/backend/internal/handlers"
)

func main() {
	cfg := config.Load()

	sqlDB, err := db.Open(cfg.DBPath)
	if err != nil {
		log.Fatalf("open database: %v", err)
	}
	defer sqlDB.Close()

	if err := db.Migrate(sqlDB); err != nil {
		log.Fatalf("run migrations: %v", err)
	}

	authHandler := handlers.NewAuthHandler(sqlDB, cfg.JWTSecret)
	eventsHandler := handlers.NewEventsHandler(sqlDB)
	checklistHandler := handlers.NewChecklistHandler(sqlDB)
	vendorsHandler := handlers.NewVendorsHandler(sqlDB)
	guestsHandler := handlers.NewGuestsHandler(sqlDB)
	tablesHandler := handlers.NewTablesHandler(sqlDB)

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Get("/api/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		if err := sqlDB.Ping(); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			json.NewEncoder(w).Encode(map[string]string{"status": "error", "db": "unreachable"})
			return
		}
		json.NewEncoder(w).Encode(map[string]string{"status": "ok", "db": "connected"})
	})

	r.Route("/api/auth", func(r chi.Router) {
		r.Post("/register", authHandler.Register)
		r.Post("/login", authHandler.Login)

		r.Group(func(r chi.Router) {
			r.Use(auth.Middleware(cfg.JWTSecret))
			r.Get("/me", authHandler.Me)
		})
	})

	r.Route("/api/events", func(r chi.Router) {
		r.Use(auth.Middleware(cfg.JWTSecret))
		r.Get("/", eventsHandler.List)
		r.Post("/", eventsHandler.Create)
		r.Route("/{eventId}", func(r chi.Router) {
			r.Get("/", eventsHandler.Get)
			r.Put("/", eventsHandler.Update)
			r.Delete("/", eventsHandler.Delete)

			r.Route("/checklist", func(r chi.Router) {
				r.Get("/", checklistHandler.List)
				r.Post("/", checklistHandler.Create)
				r.Put("/{itemId}", checklistHandler.Update)
				r.Delete("/{itemId}", checklistHandler.Delete)
			})

			r.Route("/vendors", func(r chi.Router) {
				r.Get("/", vendorsHandler.List)
				r.Post("/", vendorsHandler.Create)
				r.Put("/{vendorId}", vendorsHandler.Update)
				r.Delete("/{vendorId}", vendorsHandler.Delete)
			})

			r.Route("/guests", func(r chi.Router) {
				r.Get("/", guestsHandler.List)
				r.Post("/", guestsHandler.Create)
				r.Put("/{guestId}", guestsHandler.Update)
				r.Delete("/{guestId}", guestsHandler.Delete)
				r.Patch("/{guestId}/table", guestsHandler.UpdateTable)
			})

			r.Route("/tables", func(r chi.Router) {
				r.Get("/", tablesHandler.List)
				r.Post("/", tablesHandler.Create)
				r.Put("/{tableId}", tablesHandler.Update)
				r.Delete("/{tableId}", tablesHandler.Delete)
			})
		})
	})

	log.Printf("listening on :%s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, r); err != nil {
		log.Fatal(err)
	}
}
