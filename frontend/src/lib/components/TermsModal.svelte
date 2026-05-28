<script lang="ts">
	import { browser } from '$app/environment';

	const STORAGE_KEY = 'audimundial_terms_accepted';

	import { auth } from '$lib/auth.svelte';

	let ready = $state(false);
	let accepted = $state(browser ? !!localStorage.getItem(STORAGE_KEY) : true);

	$effect(() => {
		const t = setTimeout(() => (ready = true), 800);
		return () => clearTimeout(t);
	});
	let checked = $state(false);

	function accept() {
		if (!checked) return;
		localStorage.setItem(STORAGE_KEY, '1');
		accepted = true;
	}
</script>

{#if ready && auth.isAuthed && !accepted && browser}
	<div class="overlay">
		<div class="modal">
			<img class="logo" src="/logos/audired-logo.png" alt="AudiRed" />
			<h2>Términos y condiciones de uso</h2>
			<h3>AudiMundial 2026</h3>

			<div class="body">
				<p><strong>1. Participantes elegibles</strong><br/>
				Pueden participar todos los colaboradores y contratados de AudiRed. Solo serán elegibles para premios quienes obtengan las máximas puntuaciones al finalizar el torneo, siempre que mantengan una conducta acorde a las presentes condiciones.</p>

				<p><strong>2. Múltiples cuentas</strong><br/>
				Un mismo participante puede registrarse con más de una cuenta para seguir diferentes estrategias de pronóstico. La organización no se responsabiliza por confusiones, pérdidas de acceso o cualquier inconveniente derivado del uso de múltiples cuentas. Cada cuenta compite de manera independiente.</p>

				<p><strong>3. Acceso a la plataforma</strong><br/>
				La aplicación es accesible desde dentro y fuera de la red corporativa, y desde cualquier dispositivo con acceso a internet. El participante es responsable de la seguridad de sus credenciales de acceso.</p>

				<p><strong>4. Conducta</strong><br/>
				La organización se reserva el derecho de suspender o eliminar la cuenta de cualquier participante que incurra en conductas inapropiadas, acoso, lenguaje ofensivo o cualquier comportamiento que afecte negativamente la experiencia de otros participantes, sin previo aviso y sin derecho a reclamo.</p>

				<p><strong>5. Disponibilidad del servicio</strong><br/>
				La organización no garantiza la disponibilidad continua de la plataforma. Interrupciones por mantenimiento, actualizaciones o causas técnicas no darán lugar a reclamos de ningún tipo.</p>

				<p><strong>6. Resultados y puntuación</strong><br/>
				Los resultados de los partidos son obtenidos de fuentes externas. La organización no se responsabiliza por errores o demoras en la actualización de resultados que pudieran afectar la puntuación.</p>

				<p><strong>7. Premios</strong><br/>
				Los premios serán definidos y comunicados por la organización con anticipación al inicio del torneo. La organización se reserva el derecho de modificar, suspender o cancelar los premios por causas de fuerza mayor.</p>

				<p><strong>8. Privacidad</strong><br/>
				Los datos personales ingresados en la plataforma (nombre, email, foto de perfil) serán utilizados exclusivamente para el funcionamiento del juego y no serán compartidos con terceros.</p>

				<p><strong>9. Aceptación</strong><br/>
				La participación en AudiMundial 2026 implica la aceptación plena de estos términos y condiciones.</p>
			</div>

			<label class="check">
				<input type="checkbox" bind:checked />
				Leí y acepto los términos y condiciones
			</label>

			<button class="btn" disabled={!checked} onclick={accept}>
				Ingresar a AudiMundial 2026
			</button>
		</div>
	</div>
{/if}

<style>
	.overlay {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.85);
		z-index: 9999;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 1rem;
	}
	.modal {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 2rem;
		max-width: 560px;
		width: 100%;
		max-height: 90dvh;
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}
	.logo {
		height: 48px;
		width: auto;
		display: block;
		margin: 0 auto;
	}
	h2 {
		margin: 0;
		text-align: center;
		font-size: 1.1rem;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--accent);
	}
	h3 {
		margin: 0;
		text-align: center;
		font-size: 0.9rem;
		color: var(--muted);
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}
	.body {
		overflow-y: auto;
		flex: 1;
		font-size: 0.85rem;
		line-height: 1.6;
		color: var(--muted);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 1rem;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}
	.body p {
		margin: 0;
	}
	.check {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		font-size: 0.9rem;
		cursor: pointer;
	}
	.check input {
		width: 16px;
		height: 16px;
		cursor: pointer;
		accent-color: var(--accent);
	}
	.btn:disabled {
		opacity: 0.4;
		cursor: not-allowed;
	}
</style>
