<script lang="ts">
	import { auth } from '$lib/auth.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	let identity = $state('');
	let password = $state('');
	let error = $state('');
	let busy = $state(false);
	let showTerms = $state(false);

	// Después de iniciar sesión, reanudar una invitación si venía en la URL.
	let invite = $derived($page.url.searchParams.get('invite'));
	function dest() {
		return invite ? `/join/${invite}` : '/';
	}
	let registerHref = $derived(
		invite ? `/register?invite=${encodeURIComponent(invite)}` : '/register'
	);

	async function submit(e: Event) {
		e.preventDefault();
		error = '';
		busy = true;
		try {
			await auth.login(identity, password);
			goto(dest());
		} catch {
			error = 'Email o contraseña incorrectos.';
		} finally {
			busy = false;
		}
	}

	async function google() {
		error = '';
		busy = true;
		try {
			await auth.loginGoogle();
			goto(dest());
		} catch (e: unknown) {
			error =
				(e as { message?: string })?.message ?? 'Error al iniciar sesión con Google.';
		} finally {
			busy = false;
		}
	}
</script>

<div class="auth">
	<img class="brand-logo" src="/logos/audired-logo.png" alt="AudiRed" />
	<h1>AudiMundial 2026</h1>
	<p class="muted">Pronosticá el Mundial. Ganale a tus amigos.</p>

	<form class="card" onsubmit={submit}>
		{#if error}
			<div class="error">{error}</div>
		{/if}

		<div class="field">
			<label for="id">Email o usuario</label>
			<input
				id="id"
				type="text"
				bind:value={identity}
				required
				disabled={busy}
				autocomplete="username"
			/>
		</div>

		<div class="field">
			<label for="pw">Contraseña</label>
			<input
				id="pw"
				type="password"
				bind:value={password}
				required
				disabled={busy}
				autocomplete="current-password"
			/>
		</div>

		<button type="submit" class="btn" disabled={busy}>
			{busy ? 'Ingresando...' : 'Iniciar Sesión'}
		</button>

		<div class="sep">o</div>

		<button type="button" class="gsi" onclick={google} disabled={busy}>
			<img class="gsi-logo" src="/logos/g-logo.svg" alt="" />
			<span class="gsi-text">Iniciar sesión con Google</span>
		</button>
	</form>

	<p class="small muted center">
		¿No tenés una cuenta? <a href={registerHref} class="forgot">Registrate acá</a>
	</p>
	<p class="small muted center"><button class="link-btn" onclick={() => (showTerms = !showTerms)}>Ver términos y condiciones</button></p>
</div>

{#if showTerms}
<div class="overlay" onclick={() => (showTerms = false)}>
	<div class="modal" onclick={(e) => e.stopPropagation()}>
		<h2>Términos y condiciones de uso</h2>
		<h3>AudiMundial 2026</h3>
		<div class="body">
			<p><strong>1. Participantes elegibles</strong><br/>Pueden participar todos los colaboradores y contratados de AudiRed. Solo serán elegibles para premios quienes obtengan las máximas puntuaciones al finalizar el torneo.</p>
			<p><strong>2. Múltiples cuentas</strong><br/>Un mismo participante puede registrarse con más de una cuenta para seguir diferentes estrategias. La organización no se responsabiliza por confusiones derivadas del uso de múltiples cuentas.</p>
			<p><strong>3. Acceso a la plataforma</strong><br/>La aplicación es accesible desde dentro y fuera de la red corporativa, y desde cualquier dispositivo. El participante es responsable de la seguridad de sus credenciales.</p>
			<p><strong>4. Conducta</strong><br/>La organización se reserva el derecho de suspender o eliminar la cuenta de cualquier participante que incurra en conductas inapropiadas, sin previo aviso y sin derecho a reclamo.</p>
			<p><strong>5. Disponibilidad del servicio</strong><br/>La organización no garantiza la disponibilidad continua de la plataforma. Interrupciones técnicas no darán lugar a reclamos.</p>
			<p><strong>6. Resultados y puntuación</strong><br/>Los resultados provienen de fuentes externas. La organización no se responsabiliza por errores o demoras en la actualización.</p>
			<p><strong>7. Premios</strong><br/>Los premios serán comunicados con anticipación. La organización se reserva el derecho de modificarlos por causas de fuerza mayor.</p>
			<p><strong>8. Privacidad</strong><br/>Los datos personales serán utilizados exclusivamente para el funcionamiento del juego y no serán compartidos con terceros.</p>
			<p><strong>9. Aceptación</strong><br/>La participación en AudiMundial 2026 implica la aceptación plena de estos términos y condiciones.</p>
		</div>
		<button class="btn" onclick={() => (showTerms = false)}>Cerrar</button>
	</div>
</div>
{/if}

<style>
	/* Importamos Roboto para el cumplimiento estricto de la marca del botón de Google */
	@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@500&display=swap');

	.auth {
		max-width: 360px;
		margin: 8vh auto 2rem;
		padding: 0 1rem;
	}
	h1 {
		font-family: var(--font-display);
		font-size: 2.2rem;
		text-transform: uppercase;
		margin: 0 0 0.25rem;
		text-align: center;
	}
	p.muted {
		text-align: center;
		margin: 0 0 2rem;
		font-size: 0.95rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 1.1rem;
		box-shadow: var(--shadow-sm);
	}
	.error {
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.65rem 0.85rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}
	label {
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--muted);
	}
	input {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.55rem 0.75rem;
		color: var(--text);
		font-size: 0.95rem;
		width: 100%;
		transition: border-color 0.15s ease;
	}
	input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.forgot {
		color: var(--muted);
		font-weight: 600;
		text-decoration: underline;
		transition: color 0.15s ease;
	}
	.forgot:hover {
		color: var(--accent);
	}
	.sep {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin: 0.9rem 0;
		color: var(--muted);
		font-size: 0.8rem;
		text-transform: uppercase;
		letter-spacing: 0.1em;
	}
	.sep::before,
	.sep::after {
		content: '';
		flex: 1;
		height: 1px;
		background: var(--border);
	}

	/* Botón oficial de Google "Sign in with Google" */
	.gsi {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 12px;
		width: 100%;
		height: 40px;
		padding: 0 12px;
		background: #ffffff;
		border: 1px solid #747775;
		border-radius: 4px;
		color: #1f1f1f;
		font-family: 'Roboto', arial, sans-serif;
		font-size: 14px;
		font-weight: 500;
		letter-spacing: 0.25px;
		text-transform: none;
		cursor: pointer;
		transition: background-color 0.15s ease, box-shadow 0.15s ease;
	}
	.gsi:hover:not(:disabled) {
		background-color: #f2f2f2;
		box-shadow: 0 1px 2px 0 rgba(60,64,67,0.30), 0 1px 3px 1px rgba(60,64,67,0.15);
	}
	.gsi:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}
	.gsi-logo {
		width: 18px;
		height: 18px;
		flex: none;
	}
	.gsi-text {
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	.center {
		text-align: center;
		margin-top: 1.5rem;
	}
  .brand-logo {
		display: block;
		margin: 0 auto 1rem;
		height: 80px;
		width: auto;
	}

	.small { font-size: 0.85rem; }
	.link-btn {
		background: none;
		border: none;
		color: var(--accent);
		cursor: pointer;
		font: inherit;
		font-size: 0.85rem;
		padding: 0;
		text-decoration: underline;
	}
	.overlay {
		position: fixed;
		inset: 0;
		background: rgba(0,0,0,0.85);
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
	.modal h2 {
		margin: 0;
		text-align: center;
		font-size: 1rem;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--accent);
	}
	.modal h3 {
		margin: 0;
		text-align: center;
		font-size: 0.85rem;
		color: var(--muted);
		text-transform: uppercase;
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
	.body p { margin: 0; }

	.small { font-size: 0.85rem; }
	.link-btn {
		background: none;
		border: none;
		color: var(--accent);
		cursor: pointer;
		font: inherit;
		font-size: 0.85rem;
		padding: 0;
		text-decoration: underline;
	}
	.overlay {
		position: fixed;
		inset: 0;
		background: rgba(0,0,0,0.85);
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
	.modal h2 {
		margin: 0;
		text-align: center;
		font-size: 1rem;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--accent);
	}
	.modal h3 {
		margin: 0;
		text-align: center;
		font-size: 0.85rem;
		color: var(--muted);
		text-transform: uppercase;
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
	.body p { margin: 0; }
</style>
