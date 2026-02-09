document.addEventListener('DOMContentLoaded', ()=>{
  const searchBar = document.getElementById('searchBar');
  const overlay = document.getElementById('searchOverlay');
  const closeBtn = document.getElementById('closeOverlay');
  const backdrop = document.getElementById('overlayBackdrop');
  const overlayInput = document.getElementById('overlayInput');

  function openOverlay(){
    overlay.classList.remove('hidden');
    setTimeout(()=> overlayInput.focus(),50);
  }
  function closeOverlay(){
    overlay.classList.add('hidden');
  }

  searchBar.addEventListener('click', openOverlay);
  closeBtn.addEventListener('click', closeOverlay);
  backdrop.addEventListener('click', closeOverlay);

  document.addEventListener('keydown', (e)=>{
    if(e.key === 'Escape') closeOverlay();
  });
});
